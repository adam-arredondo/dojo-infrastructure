<?php
/*
Based on https://docs.aws.amazon.com/aws-sdk-php/v3/guide/service/s3-presigned-url.html
Requires SimpleXML http://stackoverflow.com/questions/35593521/php-7-simplexml
*/
require '/home/adarredondo/vendor/autoload.php';

$fileKeys = array();
$fileNames = array();
$headers = array('Title', 'Expires On', 'URL' );
$expireDate = date('M d, Y', strtotime("+7 day"));

$s3Client = new Aws\S3\S3Client([
    'profile' => 'default',
    'version' => 'latest',
    'region'  => 'us-east-1',
]);

$result = $s3Client->listObjects([
  'Bucket' => 'oz-transcoding-tuning', // REQUIRED
  'Prefix' => 'elemental/magnolia/leeco/32/test-output',
]);

$totalObjects = $result['Contents'];
$file = fopen("LeEco-Trailers3.csv","w");
fputcsv($file,$headers);

foreach ($totalObjects as $value){
    $cmd = $s3Client->getCommand('GetObject', [
        'Bucket' => 'oz-transcoding-tuning',
        'Key'    => $value['Key']
    ]);
    $signRequest = $s3Client->createPresignedRequest($cmd, '+7 days');
    $accessURL = (string) $signRequest->getUri();
    $fileName = explode("/",$value['Key']);
    $fileInfo[] = $fileName[5];
    $fileInfo[] = $expireDate;
    $fileInfo[] = $accessURL;
    $list = array(
      $fileInfo,
     );
    $file = fopen("LeEco-Trailers3.csv","a");
    foreach ($list as $field)
      {
      fputcsv($file,$field);
      }
    $fileInfo = array();
}
?>
