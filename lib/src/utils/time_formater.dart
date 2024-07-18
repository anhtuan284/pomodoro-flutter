/// [seconds] - The number of seconds
/// @return a string represent Time as format MM:SS
String formatTime(int seconds) {
  final int minutes = seconds ~/ 60;
  final int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
