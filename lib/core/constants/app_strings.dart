class AppStrings {
  // App
  static const String appName = 'BloodBridge';
  static const String tagline = 'Connect. Donate. Save Lives.';

  // Auth
  static const String enterPhone = 'Enter your mobile number';
  static const String phoneHint = '+91 98765 43210';
  static const String sendOtp = 'Send OTP';
  static const String enterOtp = 'Enter the OTP sent to';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String resendIn = 'Resend in';
  static const String otpSent = 'OTP sent successfully!';
  static const String invalidOtp = 'Invalid OTP. Please try again.';
  static const String phoneRequired = 'Please enter your phone number';
  static const String invalidPhone = 'Please enter a valid 10-digit number';

  // Roles
  static const String iAmDonor = 'I want to Donate';
  static const String iNeedBlood = 'I need Blood';
  static const String hospital = 'Hospital / NGO';

  // Home
  static const String requestBlood = 'Request Blood';
  static const String findDonors = 'Find Donors';
  static const String myDonations = 'My Donations';
  static const String urgentRequests = 'Urgent Requests Near You';
  static const String noRequests = 'No urgent requests nearby. You\'re all clear!';

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  // Errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String locationDenied = 'Location permission is required to find nearby donors.';
}
