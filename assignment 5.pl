%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getContentsFromFile(FileContents).
% True when FileContents is a list of lists (2D) matching
% what is in the file. Each item in FileContents is a
% list containing the characters of a line from the input
% file that is opened.
%
% E.g. Opening Maze2.txt
% FileContents = [['1', '5'], ['3', '0'], [-, -, -, -, -, -|...],
% [-, -, '.', '.', '.'|...], [-, -, '.', -|...],
% [-, -, '.'|...], [-, -|...], [-|...],
% [...|...]|...] .
%
getContentsFromFile(FileContents) :-
    open('C:/Users/JACKI/Desktop/Coding 2024/Prolog/Maze3.txt', read, FileStream), %Put own file name
    readFile(FileStream, FileContents),
    close(FileStream).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readFile(FileStream, LinesRead).
% FileStream should be an open file, and LinesRead are
% formed. LinesRead will be a list of lists (2D) of
%AUCSC 370 - Programming Languages
%The Prolog You May Use
%© Rosanna Heise
%© R. Heise 2
% characters. Each line will be one entry in LinesRead.
%
readFile(FileStream, []) :- at_end_of_stream(FileStream).
readFile(FileStream, [ALineAsList | RestOfLines]) :-
    \+ at_end_of_stream(FileStream),
    read_string(FileStream, "\n", "", _, ALineAsString),
    string_chars(ALineAsString, ALineAsList),
    readFile(FileStream, RestOfLines).

nth([First | _], 0, First).
nth([_ | Rest], N, Answer) :-
    NewN is N - 1,
    nth(Rest, NewN, Answer).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ijth(A2DList, Row, Col, IJthItem).
% True if IJthItem is the item in A2DList in the given Row and Col.
%
% NOTE:  0-based indexing.
%

ijth(GameBoard, Row, Col, IJthItem) :-
    nth(GameBoard, Row, TheRow),
    nth(TheRow, Col, IJthItem).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%returns size of the maze and also the maze without the numbers
findSize([Col, Row | Rest], Rest, Col, Row).

listNum(List, Number) :-
    listNumHelper(List, 0, Number).

listNumHelper([], Number, Number).
listNumHelper([DigitChar | Rest], Count, Number) :-
    char_code(DigitChar, DigitASCII),
    Digit is DigitASCII - 48,  % Convert character to numeric digit
    NewCount is Count * 10 + Digit,  % Update the accumulated number
    listNumHelper(Rest, NewCount, Number).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print2D(Grid).
% Prints out a list of lists (Grid) to standard output so it looks 2
% dimensional.
%
print2D([]) :- nl.
print2D([FirstRow | Rest]) :-
    printRow(FirstRow),
    print2D(Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% printRow(ARow).
% Helper to print2D, used to print a single row of a 2D board.
%
printRow([]) :- nl.
printRow([Item | Rest]) :-
    writef(Item), %field width of 7, centered
    printRow(Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%position_of(Element, [], X)
%Goes through a 1D list and looks for the given element
position_of(Element, [Element | _], 0).
position_of(Element, [_ | Tail], Index) :-
    position_of(Element, Tail, Index1),
    Index is Index1 + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PositionPlayer(player, Maze, Row, Col)
%Goes down each column of a 2D list and calls
%position_of() to find the location of the player
%Character
% Predicate to find the position of an individual element in the 2D maze
positionPlayer(Element, [RowList | _], 0, Col) :-
    position_of(Element, RowList, Col). % Use 1D position_of predicate
positionPlayer(Element, [_ | Rest], RowIndex, ColIndex) :-
    positionPlayer(Element, Rest, RowIndex1, ColIndex),
    RowIndex is RowIndex1 + 1.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ChangeIndexedToPlayer(Board, NewBoard, Row, Col, Player).
% True if NewBoard is the same as Board, except that the
% entry in location [Row][Col] is now Player.
%
move(Maze, NewMaze, Row, Col, Player) :-
    nth(Maze, Row, TheRow),
    changeRowAtIndex(TheRow, NewRow, Col, Player),
    changeRowAtIndex(Maze, NewMaze, Row, NewRow).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% changeRowAtIndex(Row, NewRow, Index, Player).
% True if NewRow is the same as Row, except that the entry
% in location Index is now Player.
%
%

changeRowAtIndex([_ | Rest], [NewValue | Rest], 0, NewValue).
changeRowAtIndex([First | Rest], [First | RestAnswer], N, NewValue) :-
    N > 0,
    NewN is N - 1,
    changeRowAtIndex(Rest, RestAnswer, NewN, NewValue).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%movePlayer(input, Maze, MazeUpdated, Mazefinal, X, Y, X1, Y1, Next)
%moves the player and returns the updated maze and positions
%does not change if a wall is hit
%
%
movePlayer(['Q' | _], _, _, _, _, _, _, _, _, _, _) :-
    writeln("Quitting game.").

movePlayer(['D' | _], Maze, _, MazeFinal, X, Y, _, _, _, LimitX, _) :-
    X1Temp is X + 1,
    X1Temp > LimitX - 1,
    move(Maze, MazeFinal, X, Y, '^'),
    MazeFinal = MazeFinal.

movePlayer(['D' | _], Maze, MazeUpdated, MazeFinal, X, Y, X1, Y1, Next, _, _) :-
    writeln("Moving down"),
    Y1Temp is Y,
    X1Temp is X + 1,
    ijth(Maze, X1Temp, Y1Temp, Next),
    Next \= '-',
    X1 is X1Temp,
    Y1 is Y1Temp,
    move(Maze, MazeUpdated, X, Y, ' '),
    move(MazeUpdated, MazeFinal, X1, Y1, '^').

movePlayer(['D' | _], Maze, _, MazeFinal, X, Y, X, Y, Next, _, _) :-
    Y1 is Y,
    X1 is X + 1,
    ijth(Maze, X1, Y1, Next),
    Next = '-', % The next position is a wall
    writeln("Next position is a wall"),
    move(Maze, MazeFinal, X, Y, '^'),
    MazeFinal = MazeFinal.

movePlayer(['U' | _], Maze, _, MazeFinal, X, Y,  _, -1, _, _, _) :-
    X1Temp is X - 1,
    X1Temp < 0,
    move(Maze, MazeFinal, X, Y, 'V'),
    MazeFinal = MazeFinal.

movePlayer(['U' | _], Maze, MazeUpdated, MazeFinal, X, Y, X1, Y1, Next, _, _) :-
    writeln("Moving Up"),
    Y1Temp is Y,
    X1Temp is X - 1,
    ijth(Maze, X1Temp, Y1Temp, Next),
    Next \= '-',
    X1 is X1Temp,
    Y1 is Y1Temp,
    move(Maze, MazeUpdated, X, Y, ' '),
    move(MazeUpdated, MazeFinal, X1, Y1, 'V').

movePlayer(['U' | _], Maze, _, MazeFinal, X, Y, X, Y, Next, _, _) :-
    Y1 is Y,
    X1 is X - 1,
    ijth(Maze, X1, Y1, Next),
    Next = '-', % The next position is a wall
    writeln("Next position is a wall"),
    move(Maze, MazeFinal, X, Y, 'V'),
    MazeFinal = MazeFinal.

%Looking for the boundary of the maze
movePlayer(['R' | _], Maze, _, MazeFinal, X, Y,  _, _, _, _, LimitY) :-
    Y1Temp is Y + 1,
    Y1Temp > LimitY - 1,
    move(Maze, MazeFinal, X, Y, '<'),
    MazeFinal = MazeFinal.


movePlayer(['R' | _], Maze, MazeUpdated, MazeFinal, X, Y, X1, Y1, Next, _, _) :-
    writeln("Moving right"),
    Y1Temp is Y + 1,
    X1Temp is X,
    ijth(Maze, X1Temp, Y1Temp, Next),
    Next \= '-',
    X1 is X1Temp,
    Y1 is Y1Temp,
    move(Maze, MazeUpdated, X, Y, ' '),
    move(MazeUpdated, MazeFinal, X1, Y1, '<').

movePlayer(['R' | _], Maze, _, MazeFinal, X, Y, X, Y, Next,_, _) :-
    Y1 is Y + 1,
    X1 is X,
    ijth(Maze, X1, Y1, Next),
    Next = '-', % The next position is a wall
    writeln("Next position is a wall"),
    move(Maze, MazeFinal, X, Y, '<'),
    MazeFinal = MazeFinal.

movePlayer(['L' | _], Maze, _, MazeFinal, X, Y,  _, -1, _, _, _) :-
    Y1Temp is Y - 1,
    Y1Temp < 0,
    move(Maze, MazeFinal, X, Y, '>'),
    MazeFinal = MazeFinal.

movePlayer(['L' | _], Maze, _, MazeFinal, X, Y, X, Y, Next,_ ,_) :-
    Y1 is Y - 1,
    X1 is X,
    ijth(Maze, X1, Y1, Next),
    Next = '-', % The next position is a wall
    writeln("Next position is a wall"),
    move(Maze, MazeFinal, X, Y, '>'),
    MazeFinal = MazeFinal.

movePlayer(['L' | _], Maze, MazeUpdated, MazeFinal, X, Y, X1, Y1, Next, _, _) :-
    writeln("Moving left"),
    move(Maze, MazeUpdated, X, Y, ' '),
    Y1 is Y - 1,
    X1 is X,
    ijth(Maze, X1, Y1, Next),
    move(MazeUpdated, MazeFinal, X1, Y1, '>').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%scoreNext()
%Depending on the next item the player moves to
%Score is added or subtracted
scoreNext('-', Score, NewScore) :-
    NewScore is Score.
scoreNext(' ', Score, NewScore) :-
    NewScore is Score - 1.
scoreNext('.', Score, NewScore) :-
    NewScore is Score + 2.
scoreNext('C', Score, NewScore) :-
    NewScore is Score + 10.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finds the position of the player position
% goes through every possible player char
% and returns the position of the valid one
posPlayer([Element | _], Maze, Row, Col) :-
    positionPlayer(Element, Maze, Row, Col).
posPlayer([_ | Rest], Maze, Row, Col) :-
    posPlayer(Rest, Maze, Row, Col).


startGame() :-
    writeln("======================================================"),
    writeln("Maze Miner"),
    writeln("Cookie Crumb = +2; Cherry = +10; Space = -1"),
    writeln("======================================================"),
    getContentsFromFile(File), findSize(File, Rest, Col, Row),
    listNum(Col, ColMaze),
    listNum(Row, RowMaze),
    posPlayer(['<', '>', '^', 'V'], Rest, Y, X),
    print2D(Rest),
    game(Rest, _, Y, X, _, _, 0, ColMaze, RowMaze, 'A').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%If X position is negative, player has exited the maze
game(_, _, _, _, _, _, _, _, _, ['Q' | _]):-
    writeln("======================================================"),
    Score is 0,
    writeln("Game Over"),
    write("Score: "),
    writeln(Score),
    writeln("======================================================").

game(_, _, -1, _, _, _, Score, _, _, _):-
    writeln("======================================================"),
    writeln("Game Over"),
    write("Score: "),
    writeln(Score),
    writeln("======================================================").

%If Y position is negative, player has exited the maze
game(_, _, _, -1, _, _, Score, _, _, _):-
    writeln("======================================================"),
    writeln("Game Over"),
    write("Score: "),
    writeln(Score),
    writeln("======================================================").

game(_, _, _, Y, _, _, Score, ExitY, _, _):-
    Y == (ExitY - 1),
    writeln("======================================================"),
    writeln("Game Over"),
    write("Score: "),
    writeln(Score),
    writeln("======================================================").

game(_, _, X, _, _, _, Score, _, ExitX, _):-
    X == (ExitX - 1),
    writeln("======================================================"),
    writeln("Game Over"),
    write("Score: "),
    writeln(Score),
    writeln("======================================================").



game(Maze, MazeUpdated, X, Y, X1, Y1, Score, ExitY, ExitX, _) :-
    writeln("Enter direction Up, Down, Left, Right: "),
    read_string(current_input, "\n", "", _, UserString),
    string_chars(UserString, UserCharList),
    movePlayer(UserCharList, Maze, _, MazeUpdated, X, Y, X1, Y1, Next, ExitY, ExitX),
    scoreNext(Next, Score, NewScore),
    write("Current score: "),
    writeln(NewScore),
    print2D(MazeUpdated),
    game(MazeUpdated, _, X1, Y1, _, _, NewScore, ExitY, ExitX, UserCharList).




