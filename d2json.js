/*
 * example
 * $ node filelist2json.js > data.json
 */

var fs = require("fs")
	, path = require("path")
	, dir = process.argv[2] || '.';


var walk = function(p, callback){
	var results = [];

	fs.readdir(p, function (err, files) {
		if (err) throw err;

		var pending = files.length;
		if (!pending) return callback(null, results);

		files.map(function (file) {
			//Get lists
			return path.join(p, file);
		}).filter(function (file) {
			if(fs.statSync(file).isDirectory()) walk(file, function(err, res) {
				//Create types from directories
				results.push({
					type: path.basename(file),
					items: res
				});
				if (!--pending) callback(null, results);
			 });
			return fs.statSync(file).isFile();
		}).forEach(function (file) {
			//Create each harvests from files
			var stat = fs.statSync(file);
			results.push({
				name: path.basename(file),
				section: path.dirname(file),
				imageUrl: "https://watarusuzuki.github.io/MealDock/images/" + path.dirname(file) + "/" + path.basename(file),
				timeStamp: 0
			});
			if (!--pending) callback(null, results);
		});

	});
}

walk(dir, function(err, results) {
	if (err) throw err;
	var data = results;
	//var data = {name:'root', children:results};
	console.log(JSON.stringify(data));
});
