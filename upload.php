<?php
	if(isset($_FILES['image'])){
		$errors= array();
		$file_name = $_FILES['image']['name'];
		$file_tmp =$_FILES['image']['tmp_name'];
		$file_type=$_FILES['image']['type'];
		$file_ext=strtolower(end(explode('.',$_FILES['image']['name'])));
		$extensions= array("txt");
		move_uploaded_file($file_tmp,"upload/".$file_name);
	}
?>

<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
</head>

<body>  
	<table>
	<tr>
		<th background="wafaray_image.png">
			<font size="+3"><p style="font-style:normal;color:yellow;font-family:Monospace;font-weight:normal;">
				.text: WARAFAY <br>
				.data: Welcom3! <br>
				.rsrc: Malware Detection
			</p></font>
		</th>
	</tr>
	<tr>
		<th><h3>Upload your file</h3></th>
	</tr>
	<tr>
		<th>
		<form action="" method="POST" enctype="multipart/form-data">
        		<input type="file" name="image" /></br></br>
        		<input type="submit"/></br>
		</form>
		</th>
	</tr>
	<tr>
		<th>RESULT: </br>
			<ul>
        			<li>Sent file: <?php echo $_FILES['image']['name'];  ?>
        			<li>File type: <?php echo $_FILES['image']['type'] ?>
			</ul>
		</th>
	</tr>
	</table>
</body>

</html>
