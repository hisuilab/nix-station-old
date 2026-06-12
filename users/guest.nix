# user/guest.nix
{
  username = "guest";
  fullName = "Guest";
  description = "Generic guest user profile";
  git = {
    userName = "guest";
    userEmail = "guest@example.com";
  };
}
