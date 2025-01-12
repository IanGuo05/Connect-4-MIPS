#   Ian Guo 
#   郭屹远
#   2023141520220
# 
#   --------------------------------------------------------------------------------------------------------------
#   **************************************************************************************************************
#   --------------------------------------------------------------------------------------------------------------
#   **************************************************************************************************************
#   --------------------------------------------------------------------------------------------------------------

# $t0: 输入的列号 (0~6)
# $t1: 当前玩家的标识符 (1 或 2)
# $t2: 列号（动态计算）
# $t3: 行号 (动态计算)
# $t4: 棋盘地址基址
# $t5: 棋盘暂时
# $t6: 放置的行数
# $t7: 棋盘位置数值
# $t8: check win 计数
.data
board:  .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
        .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
        .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, 10, 10, 10, 10, 10, 10, 10, -10, -10, -10,
        .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
        .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
        .word -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
    newline: .asciiz "\n"
    columns: .asciiz " 0 1 2 3 4 5 6\n"
    askingPlayer1: .asciiz "Player 1, it's your turn.\nSelect a column to play. Must be between 0 and 6.\n"
    askingPlayer2: .asciiz "Player 2, it's your turn.\nSelect a column to play. Must be between 0 and 6.\n"
    invalid: .asciiz "Invalid\n"
    invalid_column_tag: .asciiz "That play is invalid. Try again.\n\n"
    draw_tag: .asciiz "You fight to a draw. Congratulation!\n"
    ending_tag: .asciiz "Thanks for playing!\n"
    winner1_tag: .asciiz "Congratulations player 1. You won!\n\n"
    winner2_tag: .asciiz "Congratulations player 2. You won!\n\n"
    welcoming: .asciiz "Welcome to Connect 4. Let's begin!\n\n"

.text
main:
    li $v0, 4
    la $a0, welcoming
    syscall
    la $t9, board
    la $s1, board
    li $t1, 2
    j print_board
    
game_loop:

pre_check_board:
    li $t6, 2 # $t6 = -1
check_board:
    addi $t6, $t6, 1
    la $t4, board
    add $t4, $t4, 168
    sll $t5, $t6, 2       # 转换为字节偏移 (逻辑索引 * 4)
    add $t4, $t4, $t5     # 加上基地址，得到元素地址

    lw $t7, 0($t4)
    beq $t7, 10, ask_input # if $t7 == 0 then target
    blt $t6, 7, check_board 
    j draw

ask_input:
    blt $t1, 2, ask_player1
    bgt $t1, 1, ask_player2

ask_player1:
    li $v0, 4          # 系统调用4：打印字符串
    la $a0, askingPlayer1    # 加载列标题的地址
    syscall            # 执行系统调用
    j get_input

ask_player2:
    li $v0, 4          # 系统调用4：打印字符串
    la $a0, askingPlayer2    # 加载列标题的地址
    syscall            # 执行系统调用
    j get_input  # jump to get_input
    

get_input:
    li $v0, 5        # 读取整数
    syscall
    move $t0, $v0    # 保存用户输入到 $t0

    blt $t0, 0, invalid_column  # 小于0非法
    bgt $t0, 6, invalid_column  # 大于6非法

    # 检查列是否已满逻辑
    # 如果合法，跳转到 drop_token
    j pre_drop_token


pre_drop_token:
    li $t6, 7
drop_token:
    sub $t6, $t6, 1 #$t6 =$t6 - 1
    beq $t6, -1, invalid_input # if $t6 == -1 then invalid
    
    la $t4, board
    la $t9, board         # 加载棋盘基地址
    add $t4, $t4, 168
    add $t9, $t9, 168
    mul $t5, $t6, 13       # 行号 * 列数 (逻辑偏移量)
    add $t5, $t5, $t0     # 行偏移 + 列号 (逻辑索引)
    sll $t5, $t5, 2       # 转换为字节偏移 (逻辑索引 * 4)
    add $t4, $t4, $t5
    add $t9, $t9, $t5     # 加上基地址，得到元素地址
    li $v0, 4
    la $a0, newline
    syscall

    lw $t7, 0($t4)
    bne $t7, 10, drop_token # if $t4 != 0 then drop_token
    
    sw $t1, 0($t4)
    move $s1, $t4
    

print_board:
    # 打印列标题
    li $v0, 4          # 系统调用4：打印字符串
    la $a0, columns    # 加载列标题的地址
    syscall            # 执行系统调用

    # 打印棋盘的6行
    li $t2, 0          # 当前行索引
print_board_loop:
    li $t3, 0          # 当前列索引

    # 打印每行的开始竖线
    li $v0, 11
    li $a0, '|'
    syscall

print_column_loop:
    la $t4, board         # 加载棋盘基地址
    add $t4, $t4, 168
    mul $t5, $t2, 13      # 行号 * 列数 (逻辑偏移量)
    add $t5, $t5, $t3     # 行偏移 + 列号 (逻辑索引)
    sll $t5, $t5, 2       # 转换为字节偏移 (逻辑索引 * 4)
    add $t4, $t4, $t5     # 加上基地址，得到元素地址



    # 加载棋盘元素的值
    lw $t7, 0($t4)

    # 根据棋盘元素的值打印字符
    beq $t7, 10, print_empty
    beq $t7, 1, print_player1
    beq $t7, 2, print_player2

print_empty:
    li $v0, 11
    li $a0, '_'
    j print_char

print_player1:
    li $v0, 11
    li $a0, '*'
    j print_char

print_player2:
    li $v0, 11
    li $a0, '+'
    j print_char

print_char:
    syscall
    # 打印竖线分隔符
    li $v0, 11
    li $a0, '|'
    syscall

    # 移动到下一列
    addi $t3, $t3, 1
    blt $t3, 7, print_column_loop  # 7列

    # 换行
    li $v0, 4
    la $a0, newline
    syscall

    # 移动到下一行
    addi $t2, $t2, 1
    blt $t2, 6, print_board_loop  # 6行
    # 换行
    li $v0, 4
    la $a0, newline
    syscall

check_win:
    # li $t8, 0
    # add $t8, $t8, $t7
uu:
    add $t9, $t9, 52
    lw $t7, 0($t9)
    bne $t7, $t1, ll 
    add $t9, $t9, 52
    lw $t7, 0($t9)
    bne $t7, $t1, ll
    add $t9, $t9, 52
    lw $t7, 0($t9)
    bne $t7, $t1, ll
    blt $t1, 2, winner1
    j winner2
    
ll:
    move $t9, $s1
    add $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, l 
    add $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, l
    add $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, l
    blt $t1, 2, winner1
    j winner2

l:
    move $t9, $s1
    sub $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, r 
    add $t9, $t9, 8
    lw $t7, 0($t9)
    bne $t7, $t1, r
    add $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, r
    blt $t1, 2, winner1
    j winner2

r:
    move $t9, $s1
    add $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, rr
    sub $t9, $t9, 8
    lw $t7, 0($t9)
    bne $t7, $t1, rr
    sub $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, rr
    blt $t1, 2, winner1
    j winner2

rr:
    move $t9, $s1
    sub $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, ul
    sub $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, ul
    sub $t9, $t9, 4
    lw $t7, 0($t9)
    bne $t7, $t1, ul
    blt $t1, 2, winner1
    j winner2

ul:
    move $t9, $s1
    sub $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, ulul
    add $t9, $t9, 112
    lw $t7, 0($t9)
    bne $t7, $t1, ulul
    add $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, ulul
    blt $t1, 2, winner1
    j winner2

ulul:
    move $t9, $s1
    add $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, ur
    add $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, ur
    add $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, ur
    blt $t1, 2, winner1
    j winner2

ur:
    move $t9, $s1
    sub $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, urur
    add $t9, $t9, 96
    lw $t7, 0($t9)
    bne $t7, $t1, urur
    add $t9, $t9, 96
    lw $t7, 0($t9)
    bne $t7, $t1, urur
    blt $t1, 2, winner1
    j winner2

urur:
    move $t9, $s1
    add $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dl
    add $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dl
    add $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dl
    blt $t1, 2, winner1
    j winner2

dl:
    move $t9, $s1
    add $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dldl
    sub $t9, $t9, 96
    lw $t7, 0($t9)
    bne $t7, $t1, dldl
    sub $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dldl
    blt $t1, 2, winner1
    j winner2

dldl:
    move $t9, $s1
    sub $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dr
    sub $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dr
    sub $t9, $t9, 48
    lw $t7, 0($t9)
    bne $t7, $t1, dr
    blt $t1, 2, winner1
    j winner2

dr:
    move $t9, $s1
    add $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, drdr
    sub $t9, $t9, 112
    lw $t7, 0($t9)
    bne $t7, $t1, drdr
    sub $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, drdr
    blt $t1, 2, winner1
    j winner2

drdr:
    move $t9, $s1
    sub $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, change_player
    sub $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, change_player
    sub $t9, $t9, 56
    lw $t7, 0($t9)
    bne $t7, $t1, change_player
    blt $t1, 2, winner1
    j winner2

change_player:
    blt $t1, 2, player1to2 # if $t1 <21 one_to_twoarget
    j player2to1

player1to2:
    li $t1, 2
    j game_loop

player2to1:
    li $t1, 1
    j game_loop

invalid_input:
    # 输出"输入无效"并重新请求
    li $v0, 4
    la $a0, invalid
    syscall
    
    j ask_input

invalid_column:
    li $v0, 4
    la $a0, invalid_column_tag
    syscall
    
    j ask_input

draw:
    li $v0, 4 
    la $a0, draw_tag
    syscall
    j ending

ending:
    li $v0, 4 
    la $a0, ending_tag
    syscall
    li $v0, 10
    syscall

winner1:
    li $v0, 4 
    la $a0, winner1_tag
    syscall
    la $a0, ending_tag
    syscall
    li $v0, 10
    syscall

winner2:
    li $v0, 4 
    la $a0, winner2_tag
    syscall
    la $a0, ending_tag
    syscall
    li $v0, 10
    syscall
