import processing.serial.*;
import gohai.simpletweet.*;
import twitter4j.Query;
import twitter4j.QueryResult;
import twitter4j.Status;
import twitter4j.TwitterException;
import twitter4j.User;

SimpleTweet simpletweet;
ArrayList<Status> tweets;
Serial myPort, lcdPort;

int tn, tnold;


void setup() {
  size(500, 500);

  simpletweet = new SimpleTweet(this);
  simpletweet.setOAuthConsumerKey("xxxx"); // replace xxxx with your OAuthConsumerKey
  simpletweet.setOAuthConsumerSecret("yyyy");  // replace yyyy with your OAuthConsumerSecret
  simpletweet.setOAuthAccessToken("zzzz");  // replace zzzz with your OAuthAccessToken
  simpletweet.setOAuthAccessTokenSecret("wwww");  // replace wwww with your OAuthAccessTokenSecret

  tweets = search("#freePrometheus");
 
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
   
  myPort = new Serial(this, portName, 9600);
  myPort.write("1\n");
  delay(200);
  myPort.write("1\n");
   
  String lcdportName = Serial.list()[1]; //change the 1 to a 0 or 2 etc. to match your port
  lcdPort = new Serial(this, lcdportName, 9600);
   
  tn=tweets.size();
  tnold=tweets.size();

}

void draw() {
  background(0);
  if (frameCount % 300 == 0) {
    thread("requestData");
  }
  
  String message = " ";
  String username=" ";
  int counter=0;
  if(tweets.size()>0) {
    counter=frameCount/50 % (tweets.size());
    Status current= tweets.get(0);
    message =current.getText();
    User user = current.getUser();
    username = user.getScreenName();
  }
  text(counter+" : "+message + " by @" + username, 0, height/2);
  lcdPort.write("#freePrometheus "+username+"\n");
  delay(200);
  lcdPort.write("\n");

}

void requestData(){
    tnold=tn;
    tweets = search("#freePrometheus");
    tn=tweets.size();
    if (tn>tnold){
       myPort.write("1\n");
       delay(200);
       myPort.write("\n");
    }
}

void resetLeds(){
    myPort.write("2\n");
    delay(200);
    myPort.write("1\n");
}

void keyPressed()
{
  if(key=='0') {resetLeds();}
}

ArrayList<Status> search(String keyword) {
  // request 100 results
  Query query = new Query(keyword);
  query.setCount(100);

  try {
    QueryResult result = simpletweet.twitter.search(query);
    ArrayList<Status> tweets = (ArrayList)result.getTweets();
    // return an ArrayList of Status objects
 	return tweets;
  } catch (TwitterException e) {
    println(e.getMessage());
    return new ArrayList<Status>();
  }
}
