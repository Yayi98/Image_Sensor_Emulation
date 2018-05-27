----------------------------------------------------------------------------
--  ROW_BUFFER_test.vhd
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity ROW_BUFFER_test is

end ROW_BUFFER_test;

architecture behavior of ROW_BUFFER_test is
    component ROW_BUFFER
        port (
            ready   : out std_logic;
            clk     : in std_logic;
            wr      : in std_logic;
            load    : in std_logic;
            bit_md  : in std_logic;
            rd      : out std_logic;
            data    : in std_logic_vector(11 downto 0);
            shift   : in std_logic_vector(127 downto 0);
            rm_addr : out std_logic_vector(12 downto 0);
            pxdata  : out std_logic_vector(127 downto 0)
        );
    end component;
    signal clk     : std_logic := '0';
    signal wr      : std_logic := '0';
    signal load    : std_logic := '0';
    signal bit_md  : std_logic := '0';
    signal data    : std_logic_vector(11 downto 0) := (others => '0');
    signal shift   : std_logic_vector(127 downto 0) := (others => '0');
    signal rd      : std_logic;
    signal rm_addr : std_logic_vector(12 downto 0);
    signal pxdata  : std_logic_vector(127 downto 0);
    signal ready   : std_logic;
    constant clk_period : time := 10 ns;
begin
    uut : ROW_BUFFER port map(
        clk     => clk,
        ready   => ready,
        wr      => wr,
        load    => load,
        bit_md  => bit_md,
        rd      => rd,
        data    => data,
        shift   => shift,
        rm_addr => rm_addr,
        pxdata  => pxdata
    );
    clk_process : process

    begin

        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;

    end process;


    stim_proc : process

        variable ld_flag : std_logic := '1';
        variable rand : real;
        variable seed1, seed2 : positive;
        variable int_rand : integer;
        variable stim : std_logic_vector(11 downto 0);
        variable count : integer range 0 to 12 := 0;

    begin

        if ld_flag = '1' then
            load <= '1';
            wait for clk_period;
            load <= '0';
            wait for clk_period/2;
            ld_flag := '0';
        end if;

        if rd = '1' then
            wr <= '1';
            UNIFORM(seed1, seed2, rand);
            int_rand := integer(TRUNC(rand * 4096.0));
            stim := std_logic_vector(to_unsigned(int_rand, stim'LENGTH));
            data <= stim;
        elsif ready = '1' then
            wr <= '0';

            if count = 11 then
                count := 0;
                bit_md <= '1';
                shift <= (others => '0');
            else
                shift <= (others => '1');
                count := count + 1;
                bit_md <= '0';
            end if;

        end if;

        wait for clk_period;

    end process;
end;
