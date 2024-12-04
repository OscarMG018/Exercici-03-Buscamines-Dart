
import 'dart:ffi';
import 'dart:math';
import 'dart:io';

class Cell {
  bool isMine = false;
  int minesAround = 0;
  bool isRevealed = false;
  bool isFlagged = false;

  Cell(this.isMine, this.minesAround, this.isRevealed, this.isFlagged);

  @override
  String toString() {
    return 'Cell(isMine: $isMine, minesAround: $minesAround, isRevealed: $isRevealed, isFlagged: $isFlagged)';
  }
}

List<List<Cell>> board = [];
const int BOARD_WIDTH = 10;
const int BOARD_HEIGHT = 10;
const int MINES = 30;
bool isFirstReveal = true;
bool cheat = false;

void clearConsole() {
  if (Platform.isWindows) {
    // For Windows
    print("\x1B[2J\x1B[0;0H");
  } else {
    // For Unix-based systems
    Process.runSync("clear", [], runInShell: true);
  }
}

void createBoard() {
  for (int i = 0; i < BOARD_WIDTH; i++) {
    List<Cell> row = [];
    for (int j = 0; j < BOARD_HEIGHT; j++) {
      row.add(Cell(false, 0, false, false));
    }
    board.add(row);
  }
}

void FillMines() {
  for (int i = 0; i < MINES; i++) {
    int x = Random().nextInt(BOARD_WIDTH);
    int y = Random().nextInt(BOARD_HEIGHT);
    board[x][y].isMine = true;
  }
}

void CalculateMinesAround() {
  for (int i = 0; i < BOARD_WIDTH; i++) {
    for (int j = 0; j < BOARD_HEIGHT; j++) {
      // For each cell, calculate the number of mines around it
      int minesAround = 0;
      for (int dx in [-1, 0, 1]) {
        for (int dy in [-1, 0, 1]) {
          if (dx == 0 && dy == 0) { // Skip the current cell
            continue;
          }
          if (isPositionValid(i + dx, j + dy)) {
            if (board[i + dx][j + dy].isMine) {
              minesAround++;
            }
          }
        }
      }
      print('Mines around $i $j: $minesAround');
      board[i][j].minesAround = minesAround;
    }
  }
}

void PrintBoard() {
  for (int i = 0; i < BOARD_HEIGHT; i++) {
    for (int j = 0; j < BOARD_WIDTH; j++) {
      if (board[i][j].isFlagged) {
        stdout.write('#');
      } else if (!board[i][j].isRevealed) { // Hidden
        stdout.write('.');
      } else if (board[i][j].minesAround == 0) { // Empty
        stdout.write(' ');
      } else {
        stdout.write(board[i][j].minesAround);
      }
    }
    if (cheat) {
      stdout.write('   ');
      for (int j = 0; j < BOARD_WIDTH; j++) {
        if (board[i][j].isMine) {
          stdout.write('M');
        } else {
          stdout.write(' ');
        }
      }
    }
    print('');
  }
}

bool isPositionValid(int x, int y) {
  return x >= 0 && x < BOARD_WIDTH && y >= 0 && y < BOARD_HEIGHT;
}

bool RevealCell(int x, int y) {
  if (board[y][x].isFlagged) {
    return false;
  }
  if (board[y][x].isMine) {
    return true;
  }
  RevealAllCells(x, y);
  return false;
}

void RevealAllCells(int x, int y) {
  if (!isPositionValid(x, y)) {
    return;
  }
  if (board[y][x].isRevealed) { // Already revealed
    return;
  }
  board[y][x].isRevealed = true; // Reveal the cell
  if (board[y][x].minesAround > 0) {
    return;
  }
  for (int dx in [-1, 0, 1]) {
    for (int dy in [-1, 0, 1]) {
      if (dx != 0 || dy != 0) { // Skip the current cell
        RevealAllCells(x + dx, y + dy);
      }
    }
  }
}

void FlagCell(int x, int y) {
  board[y][x].isFlagged = !board[y][x].isFlagged;
}

void Menu() {
  while (true) {
    clearConsole();
    PrintBoard();
    print('Chose an option:');
    print('1. Reveal a cell');
    print('2. Flag/Unflag a cell');
    print('3. Exit');
    int choice = int.parse(stdin.readLineSync()!);
    if (choice == 1) {
      print('Introduce the x coordinate of the cell:');
      int x = int.parse(stdin.readLineSync()!);
      print('Introduce the y coordinate of the cell:');
      int y = int.parse(stdin.readLineSync()!);
      if (!isPositionValid(x, y)) {
        print('Invalid position!');
        continue;
      }
      if (RevealCell(x, y)) {
        if (isFirstReveal) {
          print('Your first move was a mine! but you survived!');
          board[y][x].isMine = false;
          RevealAllCells(x, y);
          continue;
        }
        print('You lost!');
        break;
      }
      isFirstReveal = false;
    } else if (choice == 2) {
      print('Introduce the x coordinate of the cell:');
      int x = int.parse(stdin.readLineSync()!);
      print('Introduce the y coordinate of the cell:');
      int y = int.parse(stdin.readLineSync()!);
      if (!isPositionValid(x, y)) {
        print('Invalid position!');
        continue;
      }
      FlagCell(x, y);
    } else if (choice == 3) {
      break;
    } else if (choice == 4) {
      cheat = !cheat;
    } else {
      print('Invalid option!');
    }
  }
}

void main() {
  createBoard();
  FillMines();
  CalculateMinesAround();
  Menu();
}