const url='http://192.168.7.107:5000/api/users/';
const baseurl='http://192.168.7.107:5000/';
const cluburl='http://192.168.7.107:5000/api/clubs/';
const matchesurl='http://192.168.7.107:5000/api/';

//player
const registration = "${url}signup";
const login = "${url}login";
const otplogin = "${url}otp-login";
const otpverify = "${url}otp-verify";
const getusers = "${url}getusers";
const getuserdetails = "${url}users/";
const issuesubmit = "${url}submit-issue";
const updateprofile = "${url}/";
const changepwd = "${url}changePassword";
const uploadProfilePicture = "${url}updateProfilePicture";
const deleteacc="${url}users/";
const addmatchstats="${url}/";

//matches

const creatematch = "${matchesurl}matches/matches";
//get all matches (upcoming event)
const getallmatch = "${matchesurl}matches/getallmatches";
const getallmatchbyid = "${matchesurl}matches/matches/user/";
const savematch = "${matchesurl}matches/users/";
const unsavematch = "${matchesurl}matches/users/";
const getsavedmatches = "${matchesurl}matches/users/";
const getmatchdetailsbyid = "${matchesurl}matches/matches/";
const addmatchstatsofteams = "${matchesurl}matches/matches/";
//club ips are no longer needed
//club
const clublogin = "${cluburl}login";
const clubregistration ="${cluburl}signup";
const reqforregistration = "${cluburl}send-request";

