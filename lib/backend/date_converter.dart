//Basic Date Setter for listing! - huehuehuehehe
  String returnCurrentDate(){
    DateTime current = DateTime.now();

    String year = current.year.toString();
    String month = addZero(current.month);
    String day = addZero(current.day);
    
    String stringDate = "$year-$month-$day";
    print(stringDate);

    return stringDate;
  }

  String addZero(int input){
    String finalValue = '';

    if (input < 10){
      finalValue = '0${input.toString()}';
      print(finalValue);
      return finalValue;
    }
    print(input.toString());
    return input.toString();
  }