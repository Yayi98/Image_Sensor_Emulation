----------------------------------------------------------------------------
--  SERIALIZER.vhd
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.NUMERIC_STD.all;

entity SERIALIZER is

    port (
        clk, rst, start, px_don : in std_logic;
        mode_sr : in std_logic_vector(6 downto 0);
        lvds_out : out std_logic_vector(63 downto 0);
        shift : out std_logic_vector(127 downto 0);
        pxdata : in std_logic_vector(127 downto 0)
    );

end SERIALIZER;


architecture Behavioral of SERIALIZER is
    signal px_out, sh_out : std_logic_vector(63 downto 0);
    signal count_inc : std_logic;
    signal px_burst : std_logic;
    type memory is array (0 to 15) of std_logic_vector(63 downto 0);
    constant filter : memory := (
    0 => x"FFFFFFFFFFFFFFFF",
    1 => x"5555555555555555",
    2 => x"1111111111111111",
    3 => x"0101010101010101",
    4 => x"0001000100010001",
    5 => x"0000000100000001",
    6 => x"0000000000000001",
    others => x"FFFFFFFFFFFFFFFF");

begin

    px_mux : process (clk, pxdata, rst, count_inc, mode_sr) is
        variable px_count : integer range - 1 to 127 := 127;

    begin

        if rising_edge(clk) then

            if rst = '1' then
                px_count := 127;
            else

                if count_inc = '1' and not(px_count = 127) then
                    px_count := px_count + 1;
                end if;

                case mode_sr(6 downto 4) is
                    when "000" =>

                        for I in 0 to 63 loop

                            if px_count < 63 then
                                px_out(I) <= pxdata(I * 2);
                                shift(I * 2) <= sh_out(I);
                            else
                                px_out(I) <= pxdata((I * 2) + 1);
                                shift((I * 2) + 1) <= sh_out(I);
                            end if;

                        end loop;

                    when others =>
                end case;

                if px_count = 127 then
                    px_burst <= '1';
                    px_count := - 1;
                else
                    px_burst <= '0';
                end if;

            end if;
        end if;

    end process;


    burst_gen : process (clk, px_out, rst, px_burst, start) is
        variable bur_count : integer range 0 to 11 := 0;
        variable strt_flag : std_logic := '0';
        variable mask : std_logic_vector(63 downto 0);
        variable temp : integer range 0 to 63 := 0;
    begin

        if rst = '1' then
            strt_flag := '0';
        elsif falling_edge(clk) then

            if start = '1' then
                strt_flag := '1';
            end if;

            if strt_flag = '1' then
                mask := filter(to_integer(unsigned(mode_sr(3 downto 1))));

                if px_burst = '1' then

                    if mask(0) = '0' then
                        mask := std_logic_vector(unsigned(mask) srl 1);
                        sh_out <= mask;
                    else
                        sh_out <= x"0000000000000000";
                        strt_flag := '0';
                    end if;

                end if;

                for I in 0 to 63 loop

                    if to_integer(unsigned(mode_sr(3 downto 1))) = 0 then
                        lvds_out(I) <= px_out(I);
                    else
                        temp := (I/to_integer(unsigned(mode_sr(3 downto 1)))) * to_integer(unsigned(mode_sr(3 downto 1)));
                        lvds_out(temp) <= px_out(I);
                    end if;

                end loop;

            end if;

        end if;
    end process;

end Behavioral;
