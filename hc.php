<?php
$reportErrors = FALSE;
$requirePost = TRUE;

/*
1. handle requestMove in app and server

2. handle move answered in app, but no request in return
*/

ob_start("ob_gzhandler");
if ($reportErrors)
{
    error_reporting(E_ALL);
}
else
{
    error_reporting(0);
}

require("hclogin.php");

function send404()
{
    //http_response_code(404);
    header('HTTP/1.0 404 Not Found');
    echo "<h1>404 Not Found</h1>";
    echo "The page that you have requested could not be found.";
    exit(0);
}

if ($requirePost)
{
    //Make sure that it is a POST request.
    if (strcasecmp($_SERVER['REQUEST_METHOD'], 'POST') != 0) 
    {
        send404();
    }
     
    //Make sure that the content type of the POST request has been set to application/json
    $contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
    
    if(strcasecmp($contentType, 'application/json; charset=utf-8') != 0) 
    {
        send404();
    }
}

//$content = '[{"wordid":7,"lang":0,"device":"34A593C2-605E-4982-B25C-7DDD84D03E24","agent":"iOS 11.3","screen":"1334.0 x 750.0"},{"wordid":7,"lang":0,"device":"XX34A593C2-605E-4982-B25C-7DDD84D03E24","agent":"iOS 11.3","screen":"1334.0 x 750.0"}]';


//$content = '[{"isCorrect" : "false","accessdate" : "2018-11-06 01:41:44","device" : "5506B663-ED80-4A9D-BCF2-23D1FB5DD89E","answerSeconds" : "2.96 sec","appversion" : "1.0","playerID" : "1","answerText" : "γγγ","screen" : "2436.0 x 1125.0","gameID" : "1","timedOut" : "false","agent" : "iOS 12.1","type" : "moveAnswer","moveID" : "1","error" : ""}]';


//$content = '[{"screen" : "1334.0 x 750.0","mood" : "1","agent" : "iOS 11.4","number" : "1","askPlayerID" : "1","device" : "34A593C2-605E-4982-B25C-7DDD84D03E24","type" : "newgame","tense" : "1","voice" : "1","error" : "","verbID" : "1","appversion" : "1.0","accessdate" : "2018-06-17 03:19:28","person" : "1","answerPlayerID" : "2"}]';

//$content = '[{"screen" : "1334.0 x 750.0","mood" : "1","agent" : "iOS 11.4","number" : "1","askPlayerID" : "1","device" : "34A593C2-605E-4982-B25C-7DDD84D03E24","type" : "getupdates","tense" : "1","voice" : "1","error" : "","verbID" : "1","appversion" : "1.0","accessdate" : "2018-06-17 03:19:28","person" : "1","answerPlayerID" : "2"}]';

//Receive the RAW post data.
$content = trim(file_get_contents("php://input"));

//$content = '[{"appversion" : "1.0","screen" : "1334.0 x 750.0","type" : "getupdates","device" : "CBDCE61E-54AF-4D75-A99A-3CD3F55ED4D2","accessdate" : "2018-11-11 06:13:32","lastGlobalGameID" : "1","lastGobalMoveID" : "1","playerID" : "2","lastUpdated" : "0","error" : "","agent" : "iOS 12.1"}]';

//$content = '[{"type" : "requestMove","gameState" : "1","moveID" : "2","error" : "","screen" : "2436.0 x 1125.0","agent" : "iOS 12.1","person" : "0","appversion" : "1.0","voice" : "1","accessdate" : "2018-11-10 01:40:02","mood" : "0","verbID" : "1","number" : "0","askPlayerID" : "1","gameID" : "1","answerPlayerID" : "2","tense" : "5","device" : "5506B663-ED80-4A9D-BCF2-23D1FB5DD89E"}]';

//$content = '[{"gameID" : "125","askPlayerID" : "2","moveID" : "2","voice" : "0","verbID" : "0","appversion" : "1.0","tense" : "0","screen" : "1334.0 x 750.0","answerPlayerID" : "2","accessdate" : "2018-11-11 23:21:29","type" : "requestMove","mood" : "0","person" : "0","gameState" : "0","device" : "CBDCE61E-54AF-4D75-A99A-3CD3F55ED4D2","agent" : "iOS 12.1","error" : "","number" : "1"}]';

//Attempt to decode the incoming RAW post data from JSON.
$decoded = json_decode($content, false);

//If json_decode failed, the JSON is invalid.
//this will always be an array, because we cache failed network attempts on device and will replay them in order.`
if (is_array($decoded) && !empty($decoded) )
{
    if (!($conn = connect($merror)))
    {
        echo "CONNECT ERROR";
    	exit(1);
    }

    $conn->query("SET @@session.time_zone='+00:00';"); //set UTC timezone
    
    foreach ($decoded as $row)
    {
        $type = $row->type; //can be newgame or answer, getupdates, ask
        $requestLastUpdated = (int)$row->lastUpdated;
        
        $agent = $conn->real_escape_string($row->agent);
        $device = $conn->real_escape_string($row->device);
        $screen = $conn->real_escape_string($row->screen);
        $appversion = $conn->real_escape_string($row->appversion);
        $ip = $conn->real_escape_string($_SERVER['REMOTE_ADDR']);
        $error = $conn->real_escape_string($row->error);

        if ($type == "newgame")
        {
            $askPlayerID = $row->askPlayerID;
            $answerPlayerID = $row->answerPlayerID;
    
            $topUnit = $row->topUnit;
            $gameState = $row->gameState;
            $timeLimit = $row->timeLimit;
            
            $verbID = $row->verbID;
            $person = $row->person;
            $number = $row->number;
            $tense = $row->tense;
            $voice = $row->voice;
            $mood = $row->mood;
        }
        else if ($type == "requestMove")
        {
            $gameID = $row->gameID;
            $moveID = $row->moveID;
            $askPlayerID = $row->askPlayerID;
            $answerPlayerID = $row->answerPlayerID;
            $gameState = $row->gameState;
            
            $verbID = $row->verbID;
            $person = $row->person;
            $number = $row->number;
            $tense = $row->tense;
            $voice = $row->voice;
            $mood = $row->mood;

        }
        else if ($type == "moveAnswer")
        {
            $isPlayer1 = ($row->isPlayer1 == "true") ? TRUE : FALSE;
            $gameID = $row->gameID;
            $moveID = $row->moveID;
            $lives = $row->lives;
            $score = $row->score;
            $playerID = $row->playerID;
            $answerIsCorrect = ($row->isCorrect == "true") ? 1 : 0;
            $answerSeconds = $conn->real_escape_string($row->answerSeconds);
            $answerTimedOut = ($row->timedOut == "true") ? 1 : 0;
            $answerText = $conn->real_escape_string($row->answerText);
        }
        else if ($type == "getupdates")
        {
            $userID = (int)$row->playerID;
        }
        //$localaccesseddate = $row->accessdate;
        
        if ($type == "answer")
        {
            $gameID = $row->gameID;
            $moveID = $row->moveID;
            $answerIsCorrect = $row->isCorrect;
            $answerText = $conn->real_escape_string($row->answerText);
            $answerSeconds = $conn->real_escape_string($row->answerSeconds);
            //$answerSeconds2 = $conn->real_escape_string($row->answerSeconds2);
            $answerTimedOut = $row->timedOut;
        }
        $success = 0;

        switch ( $type )
        {
            case "newgame":
                $moveID = 1;
                $startingNumLives = 3;
                $conn->query("BEGIN");
                $newGameQuery = sprintf("INSERT INTO hcgames VALUES (NULL,%u,%u,%u,%u,%u,%u,0,0,%u,NULL);", $topUnit, $timeLimit, $askPlayerID, $answerPlayerID, $startingNumLives, $startingNumLives, $gameState);
                
                if ( $conn->query($newGameQuery) !== FALSE)
                {
                    $gameID = $conn->insert_id;
                    
                }
                else
                {
                    $conn->query("ROLLBACK");
                    exit(1);
                }
                
                $askMoveQuery = sprintf("INSERT INTO hcmoves VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'%s','%s','%s','%s','%s','%s',%s,%s,%s,%s,%s,%s,%s,%s,NULL);", $gameID, $moveID, $verbID, $person, $number, $tense, $voice, $mood, "NULL", "NULL", "NULL", "NULL", "NULL", $askPlayerID, "Now()", $ip, $device, $screen, $agent, $appversion, $error, $answerPlayerID, "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL");
    
                if ( $conn->query($askMoveQuery) !== FALSE)
                {
                    $moveID = $conn->insert_id;
                }
                else
                {
                    $conn->query("ROLLBACK");
                    exit(1);
                }
                $conn->query("COMMIT");
                $success = 1;
                $jsonResponse  = new \stdClass();
                $jsonResponse->status = $success;
                $jsonResponse->gameID = $gameID;
                $jsonResponse->moveID = $moveID;
                //$jsonResponse->query = $realLogQuery;
                //$jsonResponse->query = $suggestionQuery;
                echo json_encode($jsonResponse);
                break;
                
            case "getupdates":
                $lastUpdate = $requestLastUpdated;
                $gameRows = [];
                $moveRows = [];
                $playerRows = [];
                $getGamesQuery = sprintf("SELECT gameid,player1,player2,topunit,timelimit,gamestate,UNIX_TIMESTAMP(lastUpdated) AS lastUpdated,player1Lives,player2Lives,player1Score,player2Score FROM hcgames WHERE UNIX_TIMESTAMP(lastUpdated) > %s AND (player1 = %s OR player2 = %s) LIMIT 500;", $requestLastUpdated, $userID, $userID);
                //echo $getGamesQuery;
                $res = $conn->query($getGamesQuery);
                if ( $res )
                {
                    while ( $r = $res->fetch_assoc() )
                    {
                        $gameRow = new \stdClass();
                        $gameRow->gameid = (int)$r["gameid"];
                        $gameRow->player1 = (int)$r["player1"];
                        $gameRow->player1Lives = (int)$r["player1Lives"];
                        $gameRow->player1Score = (int)$r["player1Score"];
                        $gameRow->player2 = (int)$r["player2"];
                        $gameRow->player2Lives = (int)$r["player2Lives"];
                        $gameRow->player2Score = (int)$r["player2Score"];
                        $gameRow->topunit = (int)$r["topunit"];
                        $gameRow->timelimit = (int)$r["timelimit"];
                        $gameRow->gamestate = (int)$r["gamestate"];
                        $gameRow->lastUpdated = (int)$r["lastUpdated"];
                        $gameRows[] = clone $gameRow;
                        $gameRow = null;
                        
                        if ( (int)$r["lastUpdated"] > $lastUpdate)
                        {
                            $lastUpdate = (int)$r["lastUpdated"];
                        }
                    }
                }
                else
                {
                    exit(1);
                }
                
                $getMovesQuery = sprintf("SELECT gameID, moveID, verbID, person, number, tense, voice, mood, answerIsCorrect, answerText, answerSeconds, answerSeconds2, answerTimedOut, askPlayerID, askTimestamp, askIP, askDevice, askScreen, askOSVersion, askAppVersion, askError, answerPlayerID, answerTimestamp, answerIP, answerDevice, answerScreen, answerOSVersion, answerAppVersion, answerError,UNIX_TIMESTAMP(lastUpdated) AS lastUpdated,answerIsCorrect,answerText,answerTimedOut,answerSeconds FROM hcmoves WHERE UNIX_TIMESTAMP(lastUpdated) > %s AND (askPlayerID = %s OR answerPlayerID = %s) LIMIT 500;", $requestLastUpdated, $userID, $userID);
                $res = $conn->query($getMovesQuery);
                if ( $res )
                {
                    while ( $r = $res->fetch_assoc() )
                    {
                        $moveRow = new \stdClass();
                        $moveRow->gameid = (int)$r["gameID"];
                        $moveRow->moveid = (int)$r["moveID"];
                        $moveRow->askPlayerID = (int)$r["askPlayerID"];
                        $moveRow->answerPlayerID = (int)$r["answerPlayerID"];
                        $moveRow->person = (int)$r["person"];
                        $moveRow->number = (int)$r["number"];
                        $moveRow->tense = (int)$r["tense"];
                        $moveRow->voice = (int)$r["voice"];
                        $moveRow->mood = (int)$r["mood"];
                        $moveRow->verbID = (int)$r["verbID"]; 
                        
                        $moveRow->answerIsCorrect = ($r["answerIsCorrect"] === NULL) ? $r["answerIsCorrect"] : (bool)$r["answerIsCorrect"];
                        $moveRow->answerText = $r["answerText"];
                        $moveRow->answerTimedOut = ($r["answerTimedOut"] === NULL) ? $r["answerTimedOut"] : (bool)$r["answerTimedOut"]; 
                        $moveRow->answerSeconds = $r["answerSeconds"]; 
                        
                        $moveRows[] = clone $moveRow;
                        $moveRow = null;
                        
                        if ( (int)$r["lastUpdated"] > $lastUpdate)
                        {
                            $lastUpdate = (int)$r["lastUpdated"];
                        }
                        
                    }
                }
                else
                {
                    exit(1);
                }
                
                $getPlayersQuery = sprintf("SELECT playerid, playername,UNIX_TIMESTAMP(lastUpdated) AS lastUpdated FROM hcplayers WHERE UNIX_TIMESTAMP(lastUpdated) > %s LIMIT 500;", $requestLastUpdated);
                $res = $conn->query($getPlayersQuery);
                if ( $res )
                {
                    while ( $r = $res->fetch_assoc() )
                    {
                        $playerRow = new \stdClass();
                        $playerRow->playerid = (int)$r["playerid"];
                        $playerRow->playername = $r["playername"];
                        $playerRows[] = clone $playerRow;
                        $playerRow = null;
                        
                        
                        if ( (int)$r["lastUpdated"] > $lastUpdate)
                        {
                            $lastUpdate = (int)$r["lastUpdated"];
                        }
                                            
                    }
                }
                else
                {
                    exit(1);
                }                
                
                $success = 1;
                $jsonResponse  = new \stdClass();
                $jsonResponse->status = $success;
                $jsonResponse->lastUpdated = (int)$lastUpdate;
                $jsonResponse->requestLastUpdated = $requestLastUpdated;
                //$jsonResponse->gameID = $gameID;
                //$jsonResponse->moveID = $moveID;
                $jsonResponse->gameRows = $gameRows;
                $jsonResponse->moveRows = $moveRows;
                $jsonResponse->playerRows = $playerRows;
                //$jsonResponse->query = $realLogQuery;
                //$jsonResponse->query = $suggestionQuery;
                echo json_encode($jsonResponse);
                break;
                
            case "moveAnswer":
                $conn->query("BEGIN");
                $answerMoveQuery = sprintf("UPDATE hcmoves SET answerIsCorrect=%s, answerText='%s', answerSeconds='%s', answerSeconds2='%s', answerTimedOut=%s, answerTimestamp=%s, answerIP='%s', answerDevice='%s', answerScreen='%s', answerOSVersion='%s', answerAppVersion='%s', answerError=%s WHERE gameid=%s AND moveid=%s LIMIT 1;",  $answerIsCorrect, $answerText, $answerSeconds, $answerSeconds2, $answerTimedOut, "NOW()", $ip, $device, $screen, $agent, $appversion, "NULL", $gameID, $moveID); //add where answerUserID = userID
                
                if ( $conn->query($answerMoveQuery) !== FALSE)
                {

                }
                else
                {
                    $success = 0;
                    $jsonResponse  = new \stdClass();
                    $jsonResponse->status = $success;
                    $jsonResponse->sql = $answerMoveQuery;
                    $jsonResponse->error = $conn->error();
                    echo json_encode($jsonResponse);  
                    $conn->query("ROLLBACK");
                    exit(1);
                }
                
                //FIX ME: if lives are 0 we need to update hcgames.gamestate to gave over
                $player = ($isPlayer1 === TRUE) ? "1" : "2";
                
                $gameOver = "";
                if ($lives < 0)
                {
                    if ($isPlayer1 === TRUE)
                    {
                        $gameOver = "SET gameState=3"; //player2 won
                    }
                    else
                    {
                        $gameOver = "SET gameState=2"; //player1 won
                    }
                }
                $answerGameQuery = sprintf("UPDATE hcgames SET player%sLives=%s, player%sScore=%s %s WHERE gameid=%s LIMIT 1;", $player, $lives, $player, $score, $gameOver, $gameID); 
                
                if ( $conn->query($answerGameQuery) !== FALSE)
                {

                }
                else
                {
                    $success = 0;
                    $jsonResponse  = new \stdClass();
                    $jsonResponse->status = $success;
                    $jsonResponse->sql = $answerMoveQuery;
                    $jsonResponse->error = $conn->error();
                    echo json_encode($jsonResponse);  
                    $conn->query("ROLLBACK");
                    exit(1);
                }
              
                $conn->query("COMMIT");
                
                $success = 1;
                $jsonResponse  = new \stdClass();
                $jsonResponse->status = $success;
                echo json_encode($jsonResponse);     
                break;
            case "requestMove":

                $conn->query("BEGIN");
                $askMoveQuery = sprintf("INSERT INTO hcmoves VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'%s','%s','%s','%s','%s','%s',%s,%s,%s,%s,%s,%s,%s,%s,NULL);", $gameID, $moveID, $verbID, $person, $number, $tense, $voice, $mood, "NULL", "NULL", "NULL", "NULL", "NULL", $askPlayerID, "Now()", $ip, $device, $screen, $agent, $appversion, $error, $answerPlayerID, "NULL", "NULL", "NULL", "NULL", "NULL", "NULL", "NULL");

                if ( $conn->query($askMoveQuery) !== FALSE)
                {
                    //$moveID = $conn->insert_id;
                }
                else
                {
                    $conn->query("ROLLBACK");
                    exit(1);
                }
                
                $updateGameStateQuery = sprintf("UPDATE hcgames SET gamestate=%d WHERE gameid=%d LIMIT 1", $gameState, $gameID);

                if ( $conn->query($updateGameStateQuery) !== FALSE)
                {
                    //$moveID = $conn->insert_id;
                }
                else
                {
                    $conn->query("ROLLBACK");
                    exit(1);
                }

                $conn->query("COMMIT");
                $success = 1;
                $jsonResponse  = new \stdClass();
                $jsonResponse->status = $success;
                $jsonResponse->gameID = $gameID;
                $jsonResponse->moveID = $moveID;
                //$jsonResponse->query = $realLogQuery;
                //$jsonResponse->query = $suggestionQuery;
                echo json_encode($jsonResponse);
                
                break;
            default:
                send404();
                break;
        }

    }

    $conn->close();
}
else
{
    send404();
}

?>
