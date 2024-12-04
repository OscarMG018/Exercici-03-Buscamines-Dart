import 'dart:math';
import 'dart:io';

class Cell {
  bool isMine = false;
  int minesAround = 0;
  bool isRevealed = false;
  bool isFlagged = false;

  Cell(this.isMine, this.minesAround, this.isRevealed, this.isFlagged);
}

List<List<Cell>> board = [];
const int BOARD_WIDTH = 10;
const int BOARD_HEIGHT = 6;
const int MINES = 8;
bool isFirstReveal = true;
bool cheat = false;

void clearConsole() {
  if (Platform.isWindows) {
    print("\x1B[2J\x1B[0;0H");
  } else {
    Process.runSync("clear", [], runInShell: true);
  }
}

void createBoard() {
  board.clear();
  for (int i = 0; i < BOARD_HEIGHT; i++) {
    List<Cell> row = [];
    for (int j = 0; j < BOARD_WIDTH; j++) {
      row.add(Cell(false, 0, false, false));
    }
    board.add(row);
  }
}

void fillMines() {
  for (int i = 0; i < MINES; i++) {
    int x = Random().nextInt(BOARD_WIDTH);
    int y = Random().nextInt(BOARD_HEIGHT);
    if (!board[y][x].isMine) {
      board[y][x].isMine = true;
    }
  }
}

void calculateMinesAround() {
  for (int i = 0; i < BOARD_HEIGHT; i++) {
    for (int j = 0; j < BOARD_WIDTH; j++) {
      if (!board[i][j].isMine) {
        int minesAround = 0;
        for (int dx in [-1, 0, 1]) {
          for (int dy in [-1, 0, 1]) {
            if (dx == 0 && dy == 0) continue;
            if (isPositionValid(j + dx, i + dy) && board[i + dy][j + dx].isMine) {
              minesAround++;
            }
          }
        }
        board[i][j].minesAround = minesAround;
      }
    }
  }
}

void printBoard() {
  stdout.write(' ');
  for (int i = 0; i < BOARD_WIDTH; i++) {
    stdout.write(i);
  }
  print('');

  for (int i = 0; i < BOARD_HEIGHT; i++) {
    stdout.write(String.fromCharCode(65 + i));
    for (int j = 0; j < BOARD_WIDTH; j++) {
      if (board[i][j].isFlagged) {
        stdout.write('#');
      } else if (!board[i][j].isRevealed) {
        stdout.write('·');
      } else if (board[i][j].isMine) {
        stdout.write('*');
      } else if (board[i][j].minesAround == 0) {
        stdout.write(' ');
      } else {
        stdout.write(board[i][j].minesAround);
      }
    }
    
    if (cheat) {
      stdout.write('     ');
      stdout.write(String.fromCharCode(65 + i));
      for (int j = 0; j < BOARD_WIDTH; j++) {
        if (board[i][j].isMine) {
          stdout.write('*');
        } else if (board[i][j].isRevealed && board[i][j].minesAround > 0) {
          stdout.write(board[i][j].minesAround);
        } else {
          stdout.write('·');
        }
      }
    }
    print('');
  }
}

bool isPositionValid(int x, int y) {
  return x >= 0 && x < BOARD_WIDTH && y >= 0 && y < BOARD_HEIGHT;
}

void revealCell(int x, int y) {
  if (!isPositionValid(x, y) || board[y][x].isRevealed || board[y][x].isFlagged) {
    return;
  }

  board[y][x].isRevealed = true;

  if (board[y][x].minesAround == 0) {
    for (int dx in [-1, 0, 1]) {
      for (int dy in [-1, 0, 1]) {
        if (dx == 0 && dy == 0) continue;
        if (isPositionValid(x + dx, y + dy)) {
          revealCell(x + dx, y + dy);
        }
      }
    }
  }
}

void revealMines() {
  for (int i = 0; i < BOARD_HEIGHT; i++) {
    for (int j = 0; j < BOARD_WIDTH; j++) {
      if (board[i][j].isMine) {
        board[i][j].isRevealed = true;
      }
    }
  }
}

void processCommand(String command) {
  command = command.trim().toUpperCase();

  if (command == "AJUDA" || command == "HELP") {
    print("Comandes: ");
    print("  - Escollir casella: lletra de la fila i número de la columna (B2, D5, ...)");
    print("  - Posar bandera: casella i paraula *flag* o *bandera*");
    print("  - Mostrar trucs: paraules *cheat* o *trampes*");
    print("  - Ajuda: paraules *help* o *ajuda*, mostren la llista de comandes");
    return;
  }

  if (command == "TRAMPES" || command == "CHEAT") {
    cheat = !cheat;
    return;
  }

  if (command.length < 2) {
    print("Comanda no vàlida!");
    return;
  }

  int row = command.codeUnitAt(0) - 65;
  int col = int.tryParse(command[1]) ?? -1;

  if (!isPositionValid(col, row)) {
    print("Posició no vàlida!");
    return;
  }

  if (command.contains("FLAG") || command.contains("BANDERA")) {
    board[row][col].isFlagged = !board[row][col].isFlagged;
  } else {
    if (board[row][col].isMine) {
      if (isFirstReveal) {
        board[row][col].isMine = false;
        calculateMinesAround();
      } else {
        revealMines();
        clearConsole();
        printBoard();
        print("Game Over!");
        exit(0);
      }
    }
    revealCell(col, row);
    isFirstReveal = false;
  }
}

void main() {
  createBoard();
  fillMines();
  calculateMinesAround();

  while (true) {
    clearConsole();
    printBoard();
    stdout.write("Escriu una comanda: ");
    String? command = stdin.readLineSync();
    if (command == null || command.isEmpty) continue;
    processCommand(command);
  }
}