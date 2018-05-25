----------------------------------------------------------------------------
--  ROW_BUFFER.vhd
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ROW_BUFFER is
    port (
        clk, wr, load, bit_md : in std_logic;                                              --bit_md: update shift register with new data 	                                           
		  rd,ready : out std_logic;                                                          --ready indicator for synthesizer
        data     : in std_logic_vector(11 downto 0);
        shift    : in std_logic_vector(127 downto 0);	                                     --shift control lines 
        rm_addr  : out std_logic_vector(12 downto 0);                                      --address for ram
        pxdata   : out std_logic_vector(127 downto 0));		 	                            --pixel data for serializer
end ROW_BUFFER;
architecture Behavioral of ROW_BUFFER is

    subtype row is std_logic_vector(11 downto 0);
    type mem is array (integer range 0 to 127, integer range 0 to 63) of row;
    signal row_var : mem;
    type sh_reg is array (integer range 0 to 127) of std_logic_vector(11 downto 0);
	 
begin

main_proc: process (clk, data, wr, load) is

        variable shift_reg : sh_reg;
        variable ld_flag, wr_flag, last_wr_flag : std_logic := '0';
        variable bit_ch : integer range 0 to 63 := 0;
        variable addr : std_logic_vector(12 downto 0) := (others => '0');
		  
    begin
	 
        if rising_edge(clk) then
				
            if load = '1' then                                                              --sets ld_flag
					 ready   <= '0';
                ld_flag := '1';
                addr    := (others => '0');
					 last_wr_flag := '0';
            end if;
				
            if ld_flag = '1' then                                                           --stays in this control until buffer filled
				
                if wr_flag = '1' then
                    rd <= '0';
						  
                    if wr = '1' then
                        row_var((to_integer(unsigned(addr(12 downto 6)))), (to_integer(unsigned(addr(5 downto 0))))) <= data;
                        wr_flag := '0';
                        addr := addr + '1';                                                 --next ram address to access
                    end if;
						  
                elsif last_wr_flag = '1' then
                    
						  for I in 0 to 127 loop						                                --updating shift register after last write
                        shift_reg(I) := row_var(I, bit_ch);
                    end loop;
						  
						  ready   <= '1';
						  ld_flag := '0';
						  
                else
                    rd <= '1';
                    rm_addr <= addr;
                    wr_flag := '1';
						  
						  if addr = x"1FFF" then
						      last_wr_flag := '1';
						  end if;
						  
                end if;
					
            else                                                      
				
                if bit_md = '1' then                                                               
				        bit_ch := bit_ch + 1;
					     
                    for I in 0 to 127 loop
                        shift_reg(I) := row_var(I, bit_ch);
                    end loop;
					 
                end if;
				
                for I in 0 to 127 loop
				
                    if shift(I) = '1' then
                        shift_reg(I) := std_logic_vector(unsigned(shift_reg(I)) srl 1);
                    end if;
					 
                    pxdata(I) <= shift_reg(I)(0);
                end loop;
				
            end if;
				end if;
		  
    end process;
	 
end Behavioral;