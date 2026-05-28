// Two separate enums - one for each loading

enum PageState{
  loading, // While screen loading - fetch data
  success, // everything worked adn loaded fine
  error // internet/firebase error - show retry button
}

enum NurseListState{
  loading, // Loading indicator on listview
  populated, // nurses loaded adn nurses list has data
  empty // nurses loaded but list is empty after filter
}