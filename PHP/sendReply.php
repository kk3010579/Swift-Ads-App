<?php 

    // VARIABLES TO SEND A REPLY
    $name = $_GET['name'];
    $fromEmail = $_GET['fromEmail'];
    $receiverEmail = $_GET['receiverEmail'];
    $tel = $_GET['tel'];
    $messageBody = $_GET['messageBody'];
    $postTitle = $_GET['postTitle'];
    

    // SUBJECT OF THE BOOKING EMAIL
    $subject = "Reply from " .$name. ", for Ad: " .$postTitle. "";

    // COMPOSE MESSAGE 
    $message = "Name: " . $name . 
    "\nEmail: " . $fromEmail .
    "\nPhone: " . $tel .
    "\n\nMessage: " . $messageBody .
    "\n\nReply to: " . $fromEmail .
    ""
    ;

    /* Finally email to you */
    mail($receiverEmail,
        $subject, 
        $message
        );

/* Result */
    echo "Email Sent";
?>
