divert(-1)dnl ------- ignore the output from all the following
changecom(`@@')

@@------------------------------
@@-- macros.m4
@@--
@@-- Usage: cat macros.m4 foo.src | m4 > foo.asm
@@--
@@-- These extensions to LC3 assembly language make programming
@@-- easier and programs more readable. In the end, it all 
@@-- ends up as plain LC3 assembly language.
@@-- 
@@-- To avoid name conflicts, the names of all our macros end
@@-- with a double underscore "__". Anywhere in .src where a
@@-- name occurs, m4 makes a text substitution, even if the name
@@-- is embedded in some other text. The "__" makes it very
@@-- unlikely a macro name will collide with any source text.
@@--
@@-- All macros that write registers set the NZP condition codes
@@-- so that subsequent branches will have the expected behavior.
@@--
@@-- Some macros use R7 as a temporary register. It's value is
@@-- saved to the stack before use, and restored after.
@@--
@@-- Caveat: While these may make programs more readable, they
@@-- introduce a level of complexity in debugging: The code that
@@-- is eventually assembled has more instructions than the
@@-- original .src code had.
@@-- 
@@-- Note that in PennSim's LC3 assembly language, "#" means
@@-- decimal notation, "x" means hex notation, and if
@@-- neither appears, the default is decimal notation.
@@--
@@-- Macros defined below:
@@--
@@-- ---- gdp__, the global data pointer.
@@-- ---- bp__, the stack base pointer.
@@-- ---- sp__, the stack pointer.
@@-- ---- FALSE__, unix-style (0) for conditionals.
@@-- ---- push__( reg ), pushing a register's contents.
@@-- ---- pop__( reg ), popping a register's contents.
@@-- ---- inc__( reg ), increment reg.
@@-- ---- dec__( reg ), decrement reg.
@@-- ---- test__( reg ), set the NZP bits w/o changing reg.
@@-- ---- mov__( reg1, reg2 ), copy reg2's content to reg1.
@@-- ---- neg__( reg ), 2s-Complement content of reg.
@@-- ---- set__( reg, val), set reg to have value val.
@@-- ---- sub__( reg1, reg2, reg3 ), reg1 <=== reg2 - reg3.
@@-- ---- or__( reg1, reg2, reg3 ), reg1 <=== reg2 OR reg3.
@@------------------------------

define(`gdp__',`R4')dnl

define(`bp__',`R5')dnl

define(`sp__',`R6')dnl

define(`FALSE__',`0')dnl

define(`push__', `
    ADD R6, R6, #-1     ;;-- push($1)
    STR $1, R6, 0        ;;--')dnl

define(`pop__',`
    LDR $1, R6, 0      ;;-- pop($1)
    ADD R6, R6, #1       ;;--')dnl

define(`inc__', `
    ADD $1, $1, #1     ;;-- inc($1)')dnl

define(`dec__', `
    ADD $1, $1, #-1    ;;-- dec($1)')dnl

define(`test__', `
    AND $1, $1, $1     ;;-- test($1)')dnl

define(`mov__', `
    ADD $1, $2, 0      ;;-- mov($1, $2)')dnl

define(`neg__', `
    NOT $1, $1         ;;-- neg($1)
    ADD $1, $1, #1       ;;-- ')dnl

define(`set__', `
    AND $1, $1, 0      ;;-- set($1, $2)
    ADD $1, $1, $2       ;;-- ')dnl

define(`sub__', `
    ADD R6, R6, -1     ;;-- sub($1, $2, $3)
    STR R7, R6, 0        ;;-- 
    NOT R7, $3           ;;--
    ADD R7, R7, 1        ;;--
    ADD $1, $2, R7       ;;--
    LDR R7, R6, 0        ;;--
    ADD R6, R6, 1        ;;-- ')dnl

define(`or__', `
    ADD R6, R6, -1     ;;-- or($1, $2, $3)
    STR R7, R6, 0        ;;-- 
    NOT $2, $2           ;;--
    NOT $3, $3           ;;--
    AND R7, $2, $3       ;;--
    NOT $2, $2           ;;--
    NOT $3, $3           ;;--
    NOT $1, R7           ;;--
    LDR R7, R6, 0        ;;--
    ADD R6, R6, 1        ;;-- ')dnl

divert(0)dnl #-- back to normal macro output.
