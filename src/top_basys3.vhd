
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_basys3 is
    port(
        -- inputs
        clk     : in std_logic; -- native 100MHz FPGA clock
        sw      : in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    : in std_logic; -- reset
        btnC    : in std_logic; -- fsm cycle

        -- outputs
        led : out std_logic_vector(15 downto 0);
        seg : out std_logic_vector(6 downto 0); -- 7-seg segments (active-low)
        an  : out std_logic_vector(3 downto 0)  -- 7-seg anodes (active-low)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is

    -- Components
    component sevenseg_decoder
        Port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    component ALU
        Port (
            i_A : in STD_LOGIC_VECTOR (7 downto 0);
            i_B : in STD_LOGIC_VECTOR (7 downto 0);
            i_op : in STD_LOGIC_VECTOR (2 downto 0);
            o_result : out STD_LOGIC_VECTOR (7 downto 0);
            o_flags : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component TDM4
        generic ( constant k_WIDTH : natural := 4 );
        Port (
            i_clk   : in  STD_LOGIC;
            i_reset : in  STD_LOGIC;
            i_D3    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D2    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D1    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D0    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_data  : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_sel   : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component clock_divider
        generic ( constant k_DIV : natural := 2 );
        port (
            i_clk    : in std_logic;
            i_reset  : in std_logic;
            o_clk    : out std_logic
        );
    end component;

    component controller_fsm
        Port (
            i_reset : in STD_LOGIC;
            i_adv   : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component twos_comp
        port (
            i_bin  : in std_logic_vector(7 downto 0);
            o_sign : out std_logic;
            o_hund : out std_logic_vector(3 downto 0);
            o_tens : out std_logic_vector(3 downto 0);
            o_ones : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals
    signal w_fsm, w_hund, w_tens, w_ones, w_dataTDM, w_TDMsel : std_logic_vector(3 downto 0);
    signal w_decoder, w_sevseg_out : std_logic_vector(6 downto 0);
    signal w_result, w_mux1 : std_logic_vector(7 downto 0);
    signal w_clk, w_sign : std_logic;
    signal w_flgs : std_logic_vector(3 downto 0);
    signal w_ff1, w_ff2 : std_logic_vector(7 downto 0);

begin

    -- Clock divider
    clkDiv_inst : clock_divider
        generic map (k_DIV => 50000)
        port map (
            i_clk   => clk,
            i_reset => btnU,
            o_clk   => w_clk
        );

    -- FSM
    fsm_inst : controller_fsm
        port map (
            i_reset => btnU,
            i_adv   => btnC,
            o_cycle => w_fsm
        );

    -- ALU
    ALU_inst : ALU
        port map (
            i_A      => w_ff1,
            i_B      => w_ff2,
            i_op     => sw(2 downto 0),
            o_result => w_result,
            o_flags  => w_flgs
        );

    -- Binary to BCD conversion
    twos_comp_inst : twos_comp
        port map (
            i_bin  => w_mux1,
            o_sign => w_sign,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );

    -- 7-segment TDM
    TDM4_inst : TDM4
        generic map (k_WIDTH => 4)
        port map (
            i_clk   => w_clk,
            i_reset => btnU,
            i_D3    => "0000",
            i_D2    => w_hund,
            i_D1    => w_tens,
            i_D0    => w_ones,
            o_data  => w_dataTDM,
            o_sel   => w_TDMsel
        );

    sevenSeg_inst : sevenseg_decoder
        port map (
            i_Hex    => w_dataTDM,
            o_seg_n  => w_decoder
        );

    -- FSM-controlled registers
    w_ff1 <= sw(7 downto 0) when w_fsm = "0001" else w_ff1;
    w_ff2 <= sw(7 downto 0) when w_fsm = "0010" else w_ff2;

    -- MUX for display input
    with w_fsm select
        w_mux1 <= w_ff1    when "0010",
                  w_ff2    when "0100",
                  w_result when others;

    -- Outputs
    an(3 downto 0)     <= w_TDMsel;
    seg(6 downto 0)    <= w_decoder;
    led(3 downto 0)    <= w_fsm;
    led(15 downto 12)  <= w_flgs;
    led(11 downto 4)   <= (others => '0'); -- unused

end top_basys3_arch;
