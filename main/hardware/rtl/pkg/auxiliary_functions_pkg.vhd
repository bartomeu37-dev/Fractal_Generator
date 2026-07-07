library ieee;
use ieee.math_real.all;

package auxiliary_functions_pkg is
    pure function calc_num_bits (max_value : natural) return natural;
end package auxiliary_functions_pkg;

package body auxiliary_functions_pkg is
    pure function calc_num_bits (max_value : natural) return natural is
    begin
        return NATURAL(ceil(log2(real(max_value + 1))));
    end function;
end package body auxiliary_functions_pkg;