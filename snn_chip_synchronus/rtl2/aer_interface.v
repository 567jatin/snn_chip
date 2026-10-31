`timescale 1ns / 1ps

// Routes source-spike events from either the external AER port or local
// neurons through the dense pre/post weight matrix. Local spikes are also
// forwarded on the outgoing AER handshake.
module aer_interface #(
    parameter NUM_NEURONS = 64,
    parameter N_BITS      = 6,
    parameter DW          = 16,
    parameter W_ADDR_W    = 2*N_BITS,
    parameter PENDING_DEPTH = 3
)(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          in_req,
    input  wire [N_BITS-1:0]             in_neuron_id,
    output reg                           in_ack,
    output reg                           pre_event,
    output reg  [N_BITS-1:0]             pre_event_id,

    output wire                          weight_rd_req,
    output wire [W_ADDR_W-1:0]           weight_rd_addr,
    input  wire                          weight_rd_ready,
    input  wire [DW-1:0]                 weight_rd_data,
    output reg  [NUM_NEURONS-1:0]        syn_valid,
    output reg  [DW-1:0]                 syn_weight,

    input  wire [NUM_NEURONS-1:0]        spike_in,
    output reg                           out_req,
    output reg  [N_BITS-1:0]             out_addr,
    input  wire                          out_ack,
    output reg                           out_overflow
);
    localparam IDLE       = 2'd0;
    localparam READ_WEIGHT= 2'd1;
    localparam DELIVER    = 2'd2;
    localparam WAIT_IN_LOW= 2'd3;
    localparam READ_RETURN= 3'd4;

    localparam PENDING_W = (PENDING_DEPTH > 1) ? $clog2(PENDING_DEPTH + 1) : 1;
    localparam PTR_W = (NUM_NEURONS > 1) ? $clog2(NUM_NEURONS) : 1;

    reg [2:0] state;
    reg [N_BITS-1:0] source_id;
    reg [N_BITS-1:0] destination;
    reg source_is_external;
    reg [NUM_NEURONS-1:0] spike_prev;
    reg [PENDING_W-1:0] route_pending [0:NUM_NEURONS-1];
    reg [PENDING_W-1:0] output_pending [0:NUM_NEURONS-1];
    reg [PTR_W-1:0] route_ptr, output_ptr;
    integer i, next_count;

    wire [NUM_NEURONS-1:0] route_pending_mask;
    wire [NUM_NEURONS-1:0] output_pending_mask;
    genvar pending_idx;
    generate
        for (pending_idx = 0; pending_idx < NUM_NEURONS; pending_idx = pending_idx + 1) begin : gen_pending_masks
            assign route_pending_mask[pending_idx] = (route_pending[pending_idx] != 0);
            assign output_pending_mask[pending_idx] = (output_pending[pending_idx] != 0);
        end
    endgenerate

    // Rotate so the round-robin pointer is bit zero, then select the first
    // pending entry with a balanced encoder instead of the modulo scan.
    wire [2*NUM_NEURONS-1:0] route_pending_double =
        {route_pending_mask, route_pending_mask};
    wire [2*NUM_NEURONS-1:0] output_pending_double =
        {output_pending_mask, output_pending_mask};
    wire [NUM_NEURONS-1:0] route_pending_rotated =
        route_pending_double >> route_ptr;
    wire [NUM_NEURONS-1:0] output_pending_rotated =
        output_pending_double >> output_ptr;

    wire route_found;
    wire output_found;
    wire [PTR_W-1:0] route_offset;
    wire [PTR_W-1:0] output_offset;
    wire [PTR_W:0] route_sum = {1'b0, route_ptr} + {1'b0, route_offset};
    wire [PTR_W:0] output_sum = {1'b0, output_ptr} + {1'b0, output_offset};
    wire [PTR_W:0] route_wrapped = (route_sum >= NUM_NEURONS) ?
                                    (route_sum - NUM_NEURONS) : route_sum;
    wire [PTR_W:0] output_wrapped = (output_sum >= NUM_NEURONS) ?
                                     (output_sum - NUM_NEURONS) : output_sum;
    wire [PTR_W-1:0] route_selected = route_wrapped[PTR_W-1:0];
    wire [PTR_W-1:0] output_selected = output_wrapped[PTR_W-1:0];

    priority_encoder #(
        .WIDTH(NUM_NEURONS), .INDEX_WIDTH(PTR_W)
    ) u_route_priority (
        .request(route_pending_rotated),
        .valid(route_found), .index(route_offset)
    );

    priority_encoder #(
        .WIDTH(NUM_NEURONS), .INDEX_WIDTH(PTR_W)
    ) u_output_priority (
        .request(output_pending_rotated),
        .valid(output_found), .index(output_offset)
    );

    assign weight_rd_req = (state == READ_WEIGHT);
    assign weight_rd_addr = {source_id, destination};

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            source_id <= {N_BITS{1'b0}};
            destination <= {PTR_W{1'b0}};
            source_is_external <= 1'b0;
            in_ack <= 1'b0;
            pre_event <= 1'b0;
            pre_event_id <= {N_BITS{1'b0}};
            syn_valid <= {NUM_NEURONS{1'b0}};
            syn_weight <= {DW{1'b0}};
            spike_prev <= {NUM_NEURONS{1'b0}};
            route_ptr <= {PTR_W{1'b0}};
            output_ptr <= {PTR_W{1'b0}};
            out_req <= 1'b0;
            out_addr <= {N_BITS{1'b0}};
            out_overflow <= 1'b0;
            for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                route_pending[i] <= {PENDING_W{1'b0}};
                output_pending[i] <= {PENDING_W{1'b0}};
            end
        end else begin
            pre_event <= 1'b0;
            syn_valid <= {NUM_NEURONS{1'b0}};

            // Keep separate queues because internal routing and external
            // forwarding must each consume every local spike event.
            for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                next_count = route_pending[i];
                if (spike_in[i] && !spike_prev[i]) begin
                    if (next_count < PENDING_DEPTH)
                        next_count = next_count + 1;
                    else
                        out_overflow <= 1'b1;
                end
                if (state == IDLE && !in_req && route_found && route_selected == i)
                    next_count = next_count - 1;
                route_pending[i] <= next_count[PENDING_W-1:0];

                next_count = output_pending[i];
                if (spike_in[i] && !spike_prev[i]) begin
                    if (next_count < PENDING_DEPTH)
                        next_count = next_count + 1;
                    else
                        out_overflow <= 1'b1;
                end
                if (!out_req && output_found && output_selected == i)
                    next_count = next_count - 1;
                output_pending[i] <= next_count[PENDING_W-1:0];
            end
            spike_prev <= spike_in;

            if (!out_req) begin
                if (output_found) begin
                    out_addr <= output_selected;
                    out_req <= 1'b1;
                end
            end else if (out_ack) begin
                out_req <= 1'b0;
                output_ptr <= (out_addr == NUM_NEURONS-1) ? {PTR_W{1'b0}} : out_addr + 1'b1;
            end

            case (state)
                IDLE: begin
                    in_ack <= 1'b0;
                    if (in_req) begin
                        source_id <= in_neuron_id;
                        destination <= {PTR_W{1'b0}};
                        source_is_external <= 1'b1;
                        pre_event <= 1'b1;
                        pre_event_id <= in_neuron_id;
                        state <= READ_WEIGHT;
                    end else if (route_found) begin
                        source_id <= route_selected;
                        destination <= {PTR_W{1'b0}};
                        source_is_external <= 1'b0;
                        route_ptr <= (route_selected == NUM_NEURONS-1) ? {PTR_W{1'b0}} : route_selected + 1'b1;
                        state <= READ_WEIGHT;
                    end
                end
                READ_WEIGHT: if (weight_rd_ready) state <= READ_RETURN;
                READ_RETURN: state <= DELIVER;
                DELIVER: begin
                    if (destination < NUM_NEURONS && weight_rd_data != 0) begin
                        syn_valid[destination] <= 1'b1;
                        syn_weight <= weight_rd_data;
                    end
                    if (destination == NUM_NEURONS-1) begin
                        if (source_is_external) begin
                            in_ack <= 1'b1;
                            state <= WAIT_IN_LOW;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        destination <= destination + 1'b1;
                        state <= READ_WEIGHT;
                    end
                end
                WAIT_IN_LOW: if (!in_req) begin
                    in_ack <= 1'b0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
