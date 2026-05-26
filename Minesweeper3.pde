// Linton & Raahini
import java.util.*;
PImage background1;

int boxSize = 45;
int cols = 10;
int rows = 8;
Cell[][] board;
boolean firstClick = true;
boolean gameOver = false;
boolean win = false;
int totalMines = 12;

void setup()
{
  size(450, 360);
  background1 = loadImage("background.png");
  resetGame();
  textAlign(CENTER, CENTER);
}

void draw()
{
  // background
  image(background1, 0, 0, width, height);

  // cells & hover
  for (int i = 0; i < cols; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      board[i][j].display();
    }
  }

  int column = mouseX / boxSize;
  int row = mouseY / boxSize;

  if (!gameOver && !win && column >= 0 && column < cols && row >= 0 && row < rows)
  {
    fill(51, 97, 189, 90);
    noStroke();
    rect(column * boxSize, row * boxSize, boxSize, boxSize);
  }

  // end screen
  if (gameOver || win)
  {
    fill(0, 170);
    rect(0, 0, width, height);

    fill(255);
    textSize(42);

    if (gameOver)
    {
      text("GAME OVER!", width / 2, height / 2 - 20);
    }
    else
    {
      text("YOU WIN!", width / 2, height / 2 - 20);
    }

    fill(255);
    rect(width/2 - 70, height/2 + 20, 140, 45);

    fill(0);
    textSize(24);
    text("RESTART", width/2, height/2 + 42);
  }
}

void mousePressed()
{
  // restart button
  if (gameOver || win)
  {
    if (mouseX >= width/2 - 70 && mouseX <= width/2 + 70 && mouseY >= height/2 + 20 && mouseY <= height/2 + 65)
    {
      resetGame();
    }

    return;
  }

  int c = mouseX / boxSize;
  int r = mouseY / boxSize;

  if (c < 0 || c >= cols || r < 0 || r >= rows)
  {
    return;
  }

  Cell cell = board[c][r];

  // first explosion
  if (firstClick)
  {
    placeMines(c, r);
    calculateNumbers();

    //starting area
    revealStartingArea(c, r);

    firstClick = false;
    return;
  }

  // place a flag
  if (mouseButton == RIGHT)
  {
    if (!cell.revealed)
    {
      cell.flagged = !cell.flagged;
    }
  }

  else if (mouseButton == LEFT)
  {
    if (!cell.flagged)
    {
      cell.reveal();

      checkWin();

      if (cell.mine)
      {
        gameOver = true;

        // reveal all mines
        for (int i = 0; i < cols; i++)
        {
          for (int j = 0; j < rows; j++)
          {
            if (board[i][j].mine)
            {
              board[i][j].revealed = true;
            }
          }
        }
      }
    }
  }
}

void resetGame()
{
  board = new Cell[cols][rows];

  for (int i = 0; i < cols; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      board[i][j] = new Cell(i, j);
    }
  }

  firstClick = true;
  gameOver = false;
  win = false;
}

void placeMines(int safeC, int safeR)
{
  int minesPlaced = 0;

  while (minesPlaced < totalMines)
  {
    int c = int(random(cols));
    int r = int(random(rows));

    Cell cell = board[c][r];

    // first click pt. 2
    if (!cell.mine && (abs(c - safeC) > 1 || abs(r - safeR) > 1))
    {
      cell.mine = true;
      minesPlaced++;
    }
  }
}

void calculateNumbers()
{
  for (int i = 0; i < cols; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      board[i][j].countNeighbors();
    }
  }
}

void revealStartingArea(int c, int r)
{
  board[c][r].reveal();
}

void checkWin()
{
  int revealedSpots = 0;

  for (int i = 0; i < cols; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      if (board[i][j].revealed && !board[i][j].mine)
      {
        revealedSpots++;
      }
    }
  }

  if (revealedSpots == cols * rows - totalMines)
  {
    win = true;
  }
}

class Cell
{
  int col;
  int row;
  boolean mine = false;
  boolean revealed = false;
  boolean flagged = false;
  int neighborCount = 0;
  
  Cell(int c, int r)
  {
    col = c;
    row = r;
  }


  void display()
  {
    int x = col * boxSize;
    int y = row * boxSize;

    // revealed cells
    if (revealed)
    {
      fill(255, 235);
      noStroke();
      rect(x, y, boxSize, boxSize);

      // draw mine
      if (mine)
      {
        fill(40);
        ellipse(x + boxSize/2, y + boxSize/2, 18, 18);
      }

      // neighboring mine count
      else if (neighborCount > 0)
      {
        if (neighborCount == 1)
        {
          fill(66, 133, 244);
        }
        else if (neighborCount == 2)
        {
          fill(52,168,83);
        }
        else if (neighborCount == 3)
        {
          fill(234, 67, 53);
        }
        else
        {
          fill(120);
        }
        textSize(24);
        text(neighborCount, x + boxSize/2, y + boxSize/2 + 1);
      }
    }
    // hidden cells
    else
    {
      fill(90, 180, 90, 65);
      noStroke();
      rect(x, y, boxSize, boxSize);

      // flag
      if (flagged)
      {
        fill(220, 40, 40);
        triangle(x + 14, y + 10, x + 14, y + 32, x + 30, y + 21);

        stroke(60);
        line(x + 14, y + 10, x + 14, y + 34);
      }
    }
  }

  void reveal()
  {
    if (revealed || flagged)
    {
      return;
    }
    revealed = true;

    // fill in empty spaces
    if (neighborCount == 0 && !mine)
    {
      for (int dx = -1; dx <= 1; dx++)
      {
        for (int dy = -1; dy <= 1; dy++)
        {
          int nc = col + dx;
          int nr = row + dy;

          if (nc >= 0 && nc < cols && nr >= 0 && nr < rows)
          {
            if (!board[nc][nr].revealed)
            {
              board[nc][nr].reveal();
            }
          }
        }
      }
    }
  }

  void countNeighbors()
  {
    if (mine)
    {
      return;
    }
    int total = 0;
    for (int dx = -1; dx <= 1; dx++)
    {
      for (int dy = -1; dy <= 1; dy++)
      {
        int nc = col + dx;
        int nr = row + dy;
        if (nc >= 0 && nc < cols && nr >= 0 && nr < rows)
        {
          if (board[nc][nr].mine)
          {
            total++;
          }
        }
      }
    }
    neighborCount = total;
  }
}
