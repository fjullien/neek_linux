--/*
-- * NEEK demo system
-- *
-- * Copyright (C) 2012 Franck JULLIEN, <elec4fun@gmail.com>
-- *
-- * See file CREDITS for list of people who contributed to this
-- * project.
-- *
-- * This program is free software; you can redistribute it and/or
-- * modify it under the terms of the GNU General Public License as
-- * published by the Free Software Foundation; either version 2 of
-- * the License, or (at your option) any later version.
-- *
-- * This program is distributed in the hope that it will be useful,
-- * but WITHOUT ANY WARRANTY; without even the implied warranty of
-- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- * GNU General Public License for more details.
-- *
-- * You should have received a copy of the GNU General Public License
-- * along with this program; if not, write to the Free Software
-- * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
-- * MA 02111-1307 USA
-- */

-----------------------------------------------------------
--                       Libraries                       --
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-----------------------------------------------------------
--                         Entity                        --
-----------------------------------------------------------

entity topNiosLinux is

port (	CLOCK_50            : in std_logic;
	KEY_CPU_RESET       : in std_logic;

	-- DDR --
	DDR_DM              : out std_logic_vector (1 downto 0);
	DDR_DQ              : inout std_logic_vector (15 downto 0);
	DDR_DQS             : inout std_logic_vector (1 downto 0);

	DDRTOP_A            : out std_logic_vector (12 downto 0);
	DDRTOP_BA           : out std_logic_vector (1 downto 0);
	DDRTOP_CAS_N        : out std_logic;
	DDRTOP_CKE          : out std_logic;
	DDRTOP_CLK          : inout std_logic;
	DDRTOP_CLK_N        : inout std_logic;
	DDRTOP_CS_N         : out std_logic;
	DDRTOP_RAS_N        : out std_logic;
	DDRTOP_WE_N         : out std_logic;

	-- FLASH SSRAM --
	FLASHSSRAM_ADDR     : out std_logic_vector (23 downto 0);
	FLASHSSRAM_DQ       : inout std_logic_vector (31 downto 0);
	FLASH_CS_N          : out std_logic;
	FLASH_OE_N          : out std_logic;
	FLASHSSRAM_RST_N    : out std_logic;
	FLASH_WR_N          : out std_logic;

	SSRAM_ADSC_N        : out std_logic;
	SSRAM_BW_N          : out std_logic_vector (3 downto 0);
	SSRAM_BWE_N         : out std_logic;
	SSRAM_CE_N          : out std_logic;
	SSRAM_OE_N          : out std_logic;
	SSRAM_CLK           : out std_logic;

	-- ETH --
	HC_TX_D             : out std_logic_vector (3 downto 0);
	HC_RX_D             : in std_logic_vector (3 downto 0);
	HC_TX_CLK           : in std_logic;
	HC_RX_CLK           : in std_logic;
	HC_TX_EN            : out std_logic;
	HC_RX_DV            : in std_logic;
	HC_RX_CRS           : in std_logic;
	HC_RX_ERR           : in std_logic;
	HC_RX_COL           : in std_logic;
	HC_MDIO             : inout std_logic;
	HC_MDC              : out std_logic;
	HC_ETH_RESET_N      : out std_logic;

	-- UART --
	UART_RXD            : in std_logic;
	UART_TXD            : out std_logic;

	-- LEDS --
	LED_DEBUG           : buffer std_logic_vector(3 downto 0)
);

end topNiosLinux;

-----------------------------------------------------------
--                     Architecture                      --
-----------------------------------------------------------

architecture RTL of topNiosLinux is

-----------------------------------------------------------
--                   Used components                     --
-----------------------------------------------------------

component linux_cpu_soc is

port (	LOCAL_REFRESH_ACK_FROM_THE_DDR_SDRAM : out   std_logic;                                        -- local_refresh_ack
	LOCAL_INIT_DONE_FROM_THE_DDR_SDRAM   : out   std_logic;                                        -- local_init_done
	RESET_PHY_CLK_N_FROM_THE_DDR_SDRAM   : out   std_logic;                                        -- reset_phy_clk_n
	MEM_CLK_TO_AND_FROM_THE_DDR_SDRAM    : inout std_logic; -- mem_clk
	MEM_CLK_N_TO_AND_FROM_THE_DDR_SDRAM  : inout std_logic; -- mem_clk_n
	MEM_CS_N_FROM_THE_DDR_SDRAM          : out   std_logic;                     -- mem_cs_n
	MEM_CKE_FROM_THE_DDR_SDRAM           : out   std_logic;                     -- mem_cke
	MEM_ADDR_FROM_THE_DDR_SDRAM          : out   std_logic_vector(12 downto 0);                    -- mem_addr
	MEM_BA_FROM_THE_DDR_SDRAM            : out   std_logic_vector(1 downto 0);                     -- mem_ba
	MEM_RAS_N_FROM_THE_DDR_SDRAM         : out   std_logic;                                        -- mem_ras_n
	MEM_CAS_N_FROM_THE_DDR_SDRAM         : out   std_logic;                                        -- mem_cas_n
	MEM_WE_N_FROM_THE_DDR_SDRAM          : out   std_logic;                                        -- mem_we_n
	MEM_DQ_TO_AND_FROM_THE_DDR_SDRAM     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- mem_dq
	MEM_DQS_TO_AND_FROM_THE_DDR_SDRAM    : inout std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_dqs
	MEM_DM_FROM_THE_DDR_SDRAM            : out   std_logic_vector(1 downto 0);                     -- mem_dm
	RXD_TO_THE_UART                      : in    std_logic                     := 'X';             -- rxd
	TXD_FROM_THE_UART                    : out   std_logic;                                        -- txd
	OUT_PORT_FROM_THE_LED_STATUS         : out   std_logic_vector(1 downto 0);                     -- export
	M_RX_D_TO_THE_TSE                    : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- m_rx_d
	M_RX_EN_TO_THE_TSE                   : in    std_logic                     := 'X';             -- m_rx_en
	M_RX_ERR_TO_THE_TSE                  : in    std_logic                     := 'X';             -- m_rx_err
	M_TX_D_FROM_THE_TSE                  : out   std_logic_vector(3 downto 0);                     -- m_tx_d
	M_TX_EN_FROM_THE_TSE                 : out   std_logic;                                        -- m_tx_en
	M_TX_ERR_FROM_THE_TSE                : out   std_logic;                                        -- m_tx_err
	TX_CLK_TO_THE_TSE                    : in    std_logic                     := 'X';             -- tx_clk
	RX_CLK_TO_THE_TSE                    : in    std_logic                     := 'X';             -- rx_clk
	SET_10_TO_THE_TSE                    : in    std_logic                     := 'X';             -- set_10
	SET_1000_TO_THE_TSE                  : in    std_logic                     := 'X';             -- set_1000
	ENA_10_FROM_THE_TSE                  : out   std_logic;                                        -- ena_10
	ETH_MODE_FROM_THE_TSE                : out   std_logic;                                        -- eth_mode
	MDIO_OUT_FROM_THE_TSE                : out   std_logic;                                        -- mdio_out
	MDIO_OEN_FROM_THE_TSE                : out   std_logic;                                        -- mdio_oen
	MDIO_IN_TO_THE_TSE                   : in    std_logic                     := 'X';             -- mdio_in
	MDC_FROM_THE_TSE                     : out   std_logic;                                        -- mdc
	WRITE_N_TO_THE_CFI                   : out   std_logic;                     -- write_n_to_the_CFI
	READ_N_TO_THE_CFI                    : out   std_logic;                     -- read_n_to_the_CFI
	ADDRESS_TO_THE_CFI                   : out   std_logic_vector(23 downto 0);                    -- address_to_the_CFI
	DATA_TO_AND_FROM_THE_CFI             : inout std_logic_vector(15 downto 0) := (others => 'X'); -- data_to_and_from_the_CFI
	SELECT_N_TO_THE_CFI                  : out   std_logic;                     -- select_n_to_the_CFI
	CLOCK_CLK                            : in    std_logic                     := 'X';             -- clk
	DDR_SDRAM_GLOBAL_RESET_N_RESET_N     : in    std_logic                     := 'X';             -- reset_n
	DDR_SDRAM_SOFT_RESET_N_RESET_N       : in    std_logic                     := 'X';             -- reset_n
	DDR_SDRAM_SYSCLK_CLK                 : out   std_logic                                         -- clk
);

end component;

-----------------------------------------------------------
--                        Constants                      --
-----------------------------------------------------------

constant SYSTEM_FREQUENCY       : natural := 100_000_000;

constant BLINK_HALF_PERIOD_MS   : natural := 250;
constant BLINK_HALF_PERIOD      : natural := (BLINK_HALF_PERIOD_MS * (SYSTEM_FREQUENCY / 1_000)) / 2;

-----------------------------------------------------------
--                          Types                        --
-----------------------------------------------------------

-----------------------------------------------------------
--                       Signals                         --
-----------------------------------------------------------

signal count        : natural range 0 to BLINK_HALF_PERIOD;
signal pio_leds     : std_logic_vector(1 downto 0);

signal MDIO_IN      : std_logic;
signal MDIO_OEN     : std_logic;
signal MDIO_OUT     : std_logic;

signal clock_100MHz : std_logic;

begin

-----------------------------------------------------------
--                 Combinatorial logic                   --
-----------------------------------------------------------

FLASHSSRAM_RST_N        <= KEY_CPU_RESET;
LED_DEBUG(3 downto 2)   <= pio_leds(1) & pio_leds(0);

HC_MDIO                 <= MDIO_OUT when MDIO_OEN = '0' else 'Z';
MDIO_IN                 <= HC_MDIO;
HC_ETH_RESET_N          <= KEY_CPU_RESET;

-----------------------------------------------------------
--                Component instantation                 --
-----------------------------------------------------------

QSYS_SOPC : linux_cpu_soc

port map (	LOCAL_REFRESH_ACK_FROM_THE_DDR_SDRAM => open,
		LOCAL_INIT_DONE_FROM_THE_DDR_SDRAM   => open,
		RESET_PHY_CLK_N_FROM_THE_DDR_SDRAM   => open,
		MEM_CLK_TO_AND_FROM_THE_DDR_SDRAM    => DDRTOP_CLK,
		MEM_CLK_N_TO_AND_FROM_THE_DDR_SDRAM  => DDRTOP_CLK_N,
		MEM_CS_N_FROM_THE_DDR_SDRAM          => DDRTOP_CS_N,
		MEM_CKE_FROM_THE_DDR_SDRAM           => DDRTOP_CKE,
		MEM_ADDR_FROM_THE_DDR_SDRAM          => DDRTOP_A,
		MEM_BA_FROM_THE_DDR_SDRAM            => DDRTOP_BA,
		MEM_RAS_N_FROM_THE_DDR_SDRAM         => DDRTOP_RAS_N,
		MEM_CAS_N_FROM_THE_DDR_SDRAM         => DDRTOP_CAS_N,
		MEM_WE_N_FROM_THE_DDR_SDRAM          => DDRTOP_WE_N,
		MEM_DQ_TO_AND_FROM_THE_DDR_SDRAM     => DDR_DQ,
		MEM_DQS_TO_AND_FROM_THE_DDR_SDRAM    => DDR_DQS,
		MEM_DM_FROM_THE_DDR_SDRAM            => DDR_DM,

		RXD_TO_THE_UART                      => UART_RXD,
		TXD_FROM_THE_UART                    => UART_TXD,

		OUT_PORT_FROM_THE_LED_STATUS         => pio_leds,

		M_RX_D_TO_THE_TSE                    => HC_RX_D,
		M_RX_EN_TO_THE_TSE                   => HC_RX_DV,
		M_RX_ERR_TO_THE_TSE                  => HC_RX_ERR,
		M_TX_D_FROM_THE_TSE                  => HC_TX_D,
		M_TX_EN_FROM_THE_TSE                 => HC_TX_EN,
		M_TX_ERR_FROM_THE_TSE                => open,
		TX_CLK_TO_THE_TSE                    => HC_TX_CLK,
		RX_CLK_TO_THE_TSE                    => HC_RX_CLK,
		SET_10_TO_THE_TSE                    => '1',
		SET_1000_TO_THE_TSE                  => '0',
		ENA_10_FROM_THE_TSE                  => open,
		ETH_MODE_FROM_THE_TSE                => open,
		MDIO_OUT_FROM_THE_TSE                => MDIO_OUT,
		MDIO_OEN_FROM_THE_TSE                => MDIO_OEN,
		MDIO_IN_TO_THE_TSE                   => MDIO_IN,
		MDC_FROM_THE_TSE                     => HC_MDC,

		WRITE_N_TO_THE_CFI                   => FLASH_WR_N,
		READ_N_TO_THE_CFI                    => FLASH_OE_N,
		ADDRESS_TO_THE_CFI                   => FLASHSSRAM_ADDR,
		DATA_TO_AND_FROM_THE_CFI             => FLASHSSRAM_DQ(15 downto 0),
		SELECT_N_TO_THE_CFI                  => FLASH_CS_N,
		CLOCK_CLK                            => CLOCK_50,
		DDR_SDRAM_GLOBAL_RESET_N_RESET_N     => KEY_CPU_RESET,
		DDR_SDRAM_SOFT_RESET_N_RESET_N       => KEY_CPU_RESET,
		DDR_SDRAM_SYSCLK_CLK			=> clock_100MHz);

-----------------------------------------------------------
--                       Processes                       --
-----------------------------------------------------------

process(clock_100MHz, KEY_CPU_RESET)

begin
	if KEY_CPU_RESET = '0' then
		count <= 0;
		LED_DEBUG(0) <= '1';
	elsif rising_edge(clock_100MHz) then
		if count < BLINK_HALF_PERIOD then
			count        <= count + 1;
		else
			count        <= 0;
			LED_DEBUG(0) <= not LED_DEBUG(0);
		end if;
	end if;
end process;

end RTL;

