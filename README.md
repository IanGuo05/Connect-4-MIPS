# Connect-4-MIPS

**Author:** Ian Guo  
**ID:** 2023141520220  
**Date:** 12/08/2024  

---

## Welcome to Connect-4  

Welcome to my **Midterm Project** - Connect 4, a part of CS 0447!  
This is a simple and fun board game implemented using **MIPS assembly** on Mars.  

### About the Game:
- It’s a **two-player game** where you can play with a friend.
- **Player 1** is the offensive player and will use `"*"` as their chess piece.
- **Player 2** is the defensive player and will use `"+"` as their chess piece.

---


### Instructions:
1. **Game Start:**  
   - The board is initialized as a 6x7 grid.  
   - Column numbers range from `0` to `6`.  

2. **Player Turns:**  
   - Players take turns choosing a column to drop their chess piece (`*` for Player 1, `+` for Player 2).  
   - The program ensures that pieces "fall" to the lowest available row in the chosen column.  

3. **Win Condition:**  
   - A player wins by aligning **4 pieces in a row**, which can be:  
     - Horizontally  
     - Vertically  
     - Diagonally  

4. **Game Over:**  
   - If the board is full and no player aligns 4 pieces, the game ends in a draw.  

---

### Features:
- **Dynamic Gameplay:** The board updates in real-time as players take turns.  
- **Input Validation:** The program ensures valid inputs (columns between 0–6 and not full).  
- **Win Detection:** Automatic checking for win conditions after each move.  

---

Enjoy the game and have fun competing with your friends! 🎮
