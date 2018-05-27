----------------------------------------------------------------------------
--  SPI_test.vhd
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity SPI_test is
    generic (
        addr_con : std_logic_vector(6 downto 0) := "1001101";
        data_con : std_logic_vector(15 downto 0) := x"BAAB");
end SPI_test;

architecture behavior of SPI_test is

    -- Component Declaration for the Unit Under Test (UUT)

    component SPI
        port (
            spi_en : in std_logic;
            spi_in : in std_logic;
            spi_clk : in std_logic;
            addr : out std_logic_vector(6 downto 0);
            data : inout std_logic_vector(15 downto 0);
            spi_out : out std_logic;
            rd : out std_logic;
            wr : out std_logic
        );
    end component;
    --Inputs
    signal spi_en : std_logic := '0';
    signal spi_in : std_logic := '0';
    signal spi_clk : std_logic := '0';

    --BiDirs
    signal data : std_logic_vector(15 downto 0);

    --Outputs
    signal addr : std_logic_vector(6 downto 0);
    signal spi_out : std_logic;
    signal rd : std_logic;
    signal wr : std_logic;
    signal start : std_logic;
    -- Clock period definitions
    constant spi_clk_period : time := 2 us;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : SPI port map(
        spi_en => spi_en,
        spi_in => spi_in,
        spi_clk => spi_clk,
        addr => addr,
        data => data,
        spi_out => spi_out,
        rd => rd,
        wr => wr
    );

    -- Clock process definitions
    spi_clk_process : process
    begin
        spi_clk <= '0';
        wait for spi_clk_period/2;
        spi_clk <= '1';
        wait for spi_clk_period/2;
    end process;
    -- Stimulus process
    stim_proc : process
        variable rd_wr : std_logic := '1';

    begin
        spi_en <= '1';
        if rd_wr = '0' then
            spi_in <= '0';
        else
            spi_in <= '1';
        end if;

        for i in 0 to 6 loop
            wait for spi_clk_period;
            spi_in <= addr_con(i);
        end loop;

        if rd_wr = '1' then
          
            for i in 0 to 15 loop
                wait for spi_clk_period;
                spi_in <= data_con(i);
            end loop;

            rd_wr := '0';
            start <= '0';
        else

            for i in 0 to 15 loop
                wait for spi_clk_period;
                spi_in <= '0';
            end loop;

            rd_wr := '1';
            start <= '0';
        end if;

        wait for spi_clk_period;
    end process;

end;
