import 'dart:developer';
import 'dart:io';

class Library with searchIndex, mainMenuProcesses{
  var allBooks, lentBooks, bookList=[], userList=[];
  List genres=["Computer Science", "Philosophy", "Pure Science", "Art and Recreation", "History"];

  //constructor that sets # of books to 0 and # of lent books to 0 for every instance of Library
  Library(){
    allBooks=0;
    lentBooks=0;
  }

  //return number of books in library's ownership including those lent out
  int numOfBooks(){
    return allBooks;
  }

  //return number of lent out books
  int numOfLent(){
    return lentBooks;
  }

  //add book to the collection
  void addBook(String title,author, genre, ISBN){
    var book=new Books(title, author, genre, ISBN);
    bookList.add(book);
    ++allBooks;
  }

  //lending a book to the user
  void lendBook(int userIndex){
    //loop does not end until user selects the finish adding option
    for(var doAddBook='a';doAddBook!='b';){

      
      stdout.write("\n(a)Add book ISBNb \n(b)Finish adding\nType choice:");
      doAddBook=stdin.readLineSync()!;

      if(doAddBook=='a'){
        //loop does not end until user inputs correct ISBN
        for(int bookIndex=-1;bookIndex==-1;){
          stdout.write("\nEnter book ISBN: ");
          String ISBNbyUser=stdin.readLineSync()!;
          bookIndex=findBookIndex(bookList, ISBNbyUser);

          //function findBookIndex returns -1 if ISBN does not match any record in the library's books collection
          if(bookIndex==-1)
            print("Book not found. Please enter ISBN again.");
          else if(bookList[bookIndex].status==0)
            print("Book is  borrowed by someone else.");
          else{
            //book is added to the user's borrowed books list
            //book's status in the library is changed to unavailable
            //library's count of lent books increments
            userList[userIndex].borrowedBooks.add(bookList[bookIndex]);
            bookList[bookIndex].status=0;
            lentBooks++;
          }
        }
      }
      else if(doAddBook=='b')
        print("\nBooks added to borrow list.\n");
      else
        print("Invalid choice. Please try again.");
    }
  }

  //library accepts returned books from user
  //all books in user's borrow list will be returned
  void acceptReturn(int userIndex){
    print("\nReturned books: ");
    if(userList[userIndex].borrowedBooks.length!=0){
      for(int i=0;i<userList[userIndex].borrowedBooks.length;){
        int bookIndex=findBookIndex(bookList, userList[userIndex].borrowedBooks[i].ISBN);
        userList[userIndex].borrowedBooks.removeAt(0);
        bookList[bookIndex].status=1;
        lentBooks--;
        print("\t${bookList[bookIndex].title} by ${bookList[bookIndex].author}");
      }
    }
    else
      print("\nNo borrowed books in your record.");
  }
  
  //adding new user
  //this method is used rather than creating an object in main method to ensure that a new User object will be
  // created only if there is an existing Library object
  void newUser(String fullName, String address){
    var user=new User(fullName, address);
    userList.add(user);
  }
}

//class for books containing necessary attributes
class Books{
  late String title;
  late String author;
  late String genre;
  late String ISBN;
  late int status; 
  var booksBorrowed=[];

  //to set values of attributes for every book instance
  Books(title, author, genre, ISBN){
    this.title=title;
    this.author=author;
    this.genre=genre;
    this.ISBN=ISBN;
    status=1; //status is immediately given value of 1 since it is available once added to collection
  }
}

//class for users containing necessary attributes
class User{
  late String fullName,address;
  var borrowedBooks=[];
  User(String fullName, String address){
    this.fullName=fullName;
    this.address=address;
  }
}

//mixin for index searching algorithms for books and users
mixin searchIndex{
  //method for finding certain book's index in library's users list
  //book is searched based on matching ISBN
  int findBookIndex(var listOfBooks, String ISBN){
    for(int i=0;i<listOfBooks.length;i++){
      if(listOfBooks[i].ISBN==ISBN)
        return i;
    }
    return -1;
  }

  //method for finding certain user's index in library's users list
  //user is searched based on matching full name and address
  int findUserIndex(var listOfUsers, String fullName, String address){
    for(int i=0;i<listOfUsers.length;i++){
      if(listOfUsers[i].fullName==fullName && listOfUsers[i].address==address)
        return i;
    }
    return -1;
  }
}

//mixin for processing of library's main menu
//chose to use mixin than defining these methods in the Library class for readability
mixin mainMenuProcesses{

  //method for browse books menu
  void mainBrowseBooks(var testLib){
    print("\n\n--BROWSE BOOKS--\n");
    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("(a)View all\n(b)View by genre\nType option: ");
      var viewBooks=stdin.readLineSync();

      //view all books regardless of genre
      if(viewBooks=='a'){
        print("\nAll available books in the collection...\n");
        for(int i=0;i<testLib.bookList.length;i++){
          if(testLib.bookList[i].status==1){
            print("Title: ${testLib.bookList[i].title}");
            print("Author: ${testLib.bookList[i].author}");
            print("Genre: ${testLib.bookList[i].genre}");
            print("ISBN: ${testLib.bookList[i].ISBN}\n");
          }
        }
        break;
      }

      //view books based on a certain genre
      else if(viewBooks=='b'){
        stdout.write("\nGenres available...\n(a)Computer Science\n(b)Philosophy\n(c)Pure Science\n(d)Art and Recreation\n(e)History\nType option: ");
        int? viewGenres=int.tryParse(stdin.readLineSync()!);

        if(viewGenres!=null && ( viewGenres>0 || viewGenres<6)){
          print("\nAvailable books in ${testLib.genres[viewGenres-1]} genre...\n");
          int c=0;

          //finding and printing books under the genre selected by user
          for(int i=0;i<testLib.bookList.length;i++){
            if(testLib.genres[viewGenres-1]==testLib.bookList[i].genre && testLib.bookList[i].status==1){
              print("Title: ${testLib.bookList[i].title}");
              print("Author: ${testLib.bookList[i].author}");
              print("ISBN: ${testLib.bookList[i].ISBN}\n");
              c++; //counter to track number of books in a certain genre
            }
          }
          if(c==0)
            print("The library has no books in that genre.\n");
          break;
        }
        else
          print("Invalid choice. Please try again.\n");
      }
      else
        print("Invalid choice. Please try again.\n");
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for borrow books menu
  void mainBorrowBooks(testLib){
    print("\n\n--BORROW BOOK/S--");
    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("\n(a)New User\n(b)Old User\nType option: "); //a for new user, b for old user
      var userStat=stdin.readLineSync();
      late int userIndex;

      if(userStat!='a' && userStat!='b')
        print("Invalid choice. Please try again.\n");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;

        //adding new user and taking index of last element in user list
        if(userStat=='a'){
          testLib.newUser(fullName, address);
          userIndex=testLib.userList.length-1;
          testLib.lendBook(userIndex);
          break;
        }
        //finding existing user and saving the index in userIndex
        else if(userStat=='b'){
          userIndex=testLib.findUserIndex(testLib.userList, fullName, address);
          if(userIndex==-1)
            print("Invalid selection. You are not an existing user. Select New User instead.");
          else{
            testLib.lendBook(userIndex);
            break;
          }
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for returning of books menu
  void mainReturnBooks(var testLib){
    print("\n\n--RETURN BOOK/S--");

    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("\n(a)New User\n(b)Old User\nType option: "); //a for new user, b for old user
      var userStat=stdin.readLineSync();

      if(userStat!='a' && userStat!='b')
        print("Invalid choice. Please try again.");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;
        
        //adding new user to library's list of users
        if(userStat=='a'){
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding user in library's user list and storing the user's index in userIndex
        else if(userStat=='b'){
          int userIndex=testLib.findUserIndex(testLib.userList, fullName, address);

          //findUserIndex returns -1 if user is not found
          if(userIndex!=-1){
            testLib.acceptReturn(userIndex);
            break;
          }
          else
            print("We cannot find your name or address. Please enter those again.");
        }
      }
    }
    print("\nRedirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for view cart menu
  void mainViewCart(testLib){
    print("\n\n--VIEW BOOKS IN CART--");

    //loop does not end until user inputs the correct choice
    for(;;){
      stdout.write("\n(a)New User\n(b)Old User\nType option: "); //a for new user, b for old user
      var userStat=stdin.readLineSync()!;

      if(userStat!='a' && userStat!='b')
        print("Invalid choice. Please try again.");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;

        //adding new user
        if(userStat=='a'){
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding existing user in the library's list of users
        else if(userStat=='b'){
          int userIndex=testLib.findUserIndex(testLib.userList, fullName, address);
          if(userIndex!=-1){
            print("\nBook/s in your cart: ");

            //printing all books in borrow list of user
            for(int i=0;i<testLib.userList[userIndex].borrowedBooks.length;i++){
              print("\t${testLib.userList[userIndex].borrowedBooks[i].title} by ${testLib.userList[userIndex].borrowedBooks[i].author}");
            }
            break;
          }
          else
            print("Are you sure you are an old user? We cannot find your name or address. Please enter again.");
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }
}

//method to test if system keeps track of books count properly
void systemTest(var testLib){
  print("---------------------------------------------------------------");
  print("This is a test.");
  print("Number of lent books: ${testLib.numOfLent()}"); 
  print("Number of books in collection: ${testLib.numOfBooks()}");
  print("---------------------------------------------------------------\n");
}

//method to add mock information to the library
void testAdd(var testLib){
  testLib.addBook("Algorithms to Live By: The Computer Science of Human Decisions", 
  "Brian Christian and Tom Griffiths", "Computer Science", "978-1-60309-047-6");
  testLib.addBook("The Soul of a New Machine", "Tracy Kidder", "Computer Science", "978-7-61209-817-6");
  testLib.addBook("Nicomachean Ethics", "Aristotle", "Philosophy", "978-1-543130-14-3");
  testLib.addBook("When Helping Hurts", "By Steve Corbett & Brian Fikkert", "History", "978-1-91409-516-6");
}

//main function starts here
void main(){
  var testLib=new Library();
  testAdd(testLib); //adding mock information of books and users to the library

  //loop does not end unless user inputs any keys other than a,b,c and d
  for(bool doExit=false;!doExit;){
    print("Welcome to the Library!");
    stdout.write("(a)Browse collection of books\n(b)Borrow book/s\n(c)Return book/s\n(d)View book/s in cart\nPress any other key to exit...\nType option: ");
    var mainOption=stdin.readLineSync();
    switch(mainOption){
      case 'a':
        //browse books
        testLib.mainBrowseBooks(testLib);        
        break;
      case 'b': 
        //borrow books
        testLib.mainBorrowBooks(testLib);
        break;
      case 'c':
        //return borrowed books
        testLib.mainReturnBooks(testLib);
        break;
      case 'd':
        //view books in cart 
        testLib.mainViewCart(testLib);
        break;
      default:
        doExit=true;
        print("Exiting...");
        
        systemTest(testLib);
    }
  }
}