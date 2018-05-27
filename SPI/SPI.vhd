----------------------------------------------------------------------------
--  ROW_BUFFER.vhd
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SPI is
    port (
        spi_en, spi_in, spi_clk : in std_logic;
        addr : out std_logic_vector(6 downto 0);                              --Address for sequencer
        data : inout std_logic_vector(15 downto 0);                           --Parallel data for sequencer
        spi_out, rd, wr : out std_logic);
end SPI;

architecture Behavioral of SPI is
    signal tr_strt : std_logic;                                               --Signal for triggering "transmitter process"

begin

    rcv_proc : process (spi_en, spi_in, spi_clk) is
        variable a_temp : integer range - 1 to 7 := 7;
        variable d_temp : integer range - 2 to 15 := 15;
        variable data_var : std_logic_vector(15 downto 0);
        variable addr_var : std_logic_vector(6 downto 0);
        variable rd_wr_fl : std_logic;
    begin

        if spi_en = '1' then
            if rising_edge(spi_clk) then
                if a_temp = 7 then
                    a_temp := a_temp - 1;
                    rd_wr_fl := spi_in;

                elsif a_temp = 0 and rd_wr_fl = '0' then
                    addr_var(a_temp) := spi_in;
                    a_temp := a_temp - 1;
                    rd <= '1';
                    tr_strt <= '1';

                elsif a_temp >- 1 then
                    addr_var(a_temp) := spi_in;
                    a_temp := a_temp - 1;

                elsif rd_wr_fl = '1' and d_temp >- 1 then
                    data_var(d_temp) := spi_in;
                    d_temp := d_temp - 1;

                elsif rd_wr_fl = '0' and d_temp >- 1 then
                    d_temp := d_temp - 1;

                elsif rd_wr_fl = '1' and d_temp =- 1 then
                    data <= data_var;
                    wr <= '1';
                    d_temp := d_temp - 1;

                else
                    rd <= '0';
                    wr <= '0';
                    tr_strt <= '0';
                    a_temp := 7;
                    d_temp := 15;

                end if;
            end if;

        else
            rd <= '0';
            wr <= '0';
            tr_strt <= '0';
            a_temp := 7;
            d_temp := 15;
        end if;

        addr <= addr_var;
    end process;

    trn_proc : process (spi_en, spi_clk, data, tr_strt) is
        variable d_temp : integer range - 1 to 15 := 15;

    begin

        if falling_edge(spi_clk) then
            if tr_strt = '1' and d_temp >- 1 then
                spi_out <= data(d_temp);
                d_temp := d_temp - 1;

            elsif tr_strt = '0' then
                spi_out <= 'Z';
                d_temp := 15;

            end if;
        end if;

    end process;
end Behavioral;
