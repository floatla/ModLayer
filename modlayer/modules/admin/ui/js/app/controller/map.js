define([
	'jquery'
	, 'Util'
], function(
	$
	, Util
){
	
	function GMap() {

		// var locallat = -34.6015;
		// var locallng = -58.3882;

		var self = this;
		self.geocoder = null;
		self.map = null;
		self.markers = [];
		

		var mrks, iw;
		self.locallat = -27.4784959;
		self.locallng = -58.9079577;

		self.initialize = function()
		{
			
			var iw;

			self.geocoder = new google.maps.Geocoder();
			var latlng = new google.maps.LatLng(self.locallat, self.locallng);
			var mapOptions = {
			  zoom: 15,
			  center: latlng,
			  scrollwheel: false,
			  mapTypeId: google.maps.MapTypeId.ROADMAP
			}
			self.map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
			marker = new google.maps.Marker({
		    	position: latlng,
		        map: self.map,
		    	draggable:true,
		    	title:'Mueva el marcador para obtener latitud y longitud'
			});

			google.maps.event.addListener(marker, 'click', function(mll) {
				self.gC(mll.latLng);
				var html= "<div style='color:#000; background-color:#fff; padding:3px;'><p>Latitude - Longitude:<br />" + String(mll.latLng.toUrlValue()) + "<br /><br />Lat: " + ls +  "&#176; " + lm +  "&#39; "  + ld + "&#34;<br />Long: " + lgs +  "&#176; " + lgm +  "&#39; " + lgd + "&#34;</p></div>";
				self.iw = new google.maps.InfoWindow({content:html});
				self.iw.open(self.map,marker);
			});

			google.maps.event.addListener(marker, 'dragstart', function() {
				if (self.iw){self.iw.close();}
			});
			

			google.maps.event.addListener(marker, 'dragend', function(event) {
				posset = 1;
				if (self.map.getZoom() < 14){self.map.setZoom(15);}
				// self.map.setCenter(event.latLng);
				self.map.panTo(event.latLng);
				self.computepos(event.latLng);
				self.updateAdressText(event.latLng);
				// showLatLong(event.latLng.lat(), event.latLng.lng());
			});

			self.mrks = {mvcMarkers: new google.maps.MVCArray()};
		}

		self.loadScript = function() 
		{
			

			if($('#GMapSource').length == 0)
			{
				var script = document.createElement("script");
				script.type = "text/javascript";
				script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyAHvuJN1fYdf_2xi46dpLWv1RqMGZ0eSh4";
				script.id  = "GMapSource";
				document.body.appendChild(script);
				script.onload = function(){ self.initialize(); };
			}
			else
			{
				setTimeout(function(){
					self.initialize();
				}, 1500);
			}

			// if($('#map-canvas').length > 0)
			// {
			
			// 	var script = document.createElement("script");
			// 	script.type = "text/javascript";
			// 	script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyCXPK3ZEwJvu_yPfkOpJV7EB7v3xvK7m-A";
			// 	document.body.appendChild(script);
			// 	script.onload = function(){ self.initialize(); };
			// }
		}

		self.codeAddress = function() {
			var address = document.getElementById("address").value;
			self.geocoder.geocode({'address': address}, self.AddressResult);
		}

		self.AddressResult = function(results, status) 
		{
			if (status == google.maps.GeocoderStatus.OK) {
				self.map.setCenter(results[0].geometry.location);
				if (self.map.getZoom() < 16){ self.map.setZoom(16);} 
				marker.setPosition(results[0].geometry.location);
				var latField = document.getElementById('lat');
				var lngField = document.getElementById('lng');
				latField.value = results[0].geometry.location.lat();
				lngField.value = results[0].geometry.location.lng();
			} else {
				window.appUI.RenderMessage("No se pudo localizar por el siguiente motivo: " + status);
			}
		}

		self.updateAdressText = function(latlng)
		{
			self.geocoder.geocode({'latLng': latlng}, function(results, status) {
		      if (status == google.maps.GeocoderStatus.OK) {
		        if (results[1]) {
		          var text = document.getElementById('address');
		          // text.value = results[1].formatted_address;
		        }
		      } else {
		        //modion.displayMessage("No se pudo obtener la direccion por: " + status);
		      }
		    });
		}
		
		self.SetLatLon = function(lat, lon)
		{
			self.locallat = lat;
			self.locallng = lon;
		}

		self.computepos = function(point)
		{
			var latA = Math.abs(Math.round(point.lat() * 1000000.));
			var lonA = Math.abs(Math.round(point.lng() * 1000000.));
			if(point.lat() < 0)
			{
				var ls = '-' + Math.floor((latA / 1000000)).toString();
			}
			else
			{
				var ls = Math.floor((latA / 1000000)).toString();
			}
			var lm = Math.floor(((latA/1000000) - Math.floor(latA/1000000)) * 60).toString();
			var ld = ( Math.floor(((((latA/1000000) - Math.floor(latA/1000000)) * 60) - Math.floor(((latA/1000000) - Math.floor(latA/1000000)) * 60)) * 100000) *60/100000 ).toString();
			if(point.lng() < 0)
			{
			  var lgs = '-' + Math.floor((lonA / 1000000)).toString();
			}
			else
			{
				var lgs = Math.floor((lonA / 1000000)).toString();
			}
			var lgm = Math.floor(((lonA/1000000) - Math.floor(lonA/1000000)) * 60).toString();
			var lgd = ( Math.floor(((((lonA/1000000) - Math.floor(lonA/1000000)) * 60) - Math.floor(((lonA/1000000) - Math.floor(lonA/1000000)) * 60)) * 100000) *60/100000 ).toString();
			document.getElementById("lat").value=point.lat().toFixed(6);
			document.getElementById("lng").value=point.lng().toFixed(6);
		}

		self.gC = function (ll)
		{
			var latA = Math.abs(Math.round(ll.lat() * 1000000.));
			var lonA = Math.abs(Math.round(ll.lng() * 1000000.));
			if(ll.lat() < 0)
			{
				var tls = '-' + Math.floor((latA / 1000000)).toString();
			}
			else
			{
				var tls = Math.floor((latA / 1000000)).toString();
			}
			var tlm = Math.floor(((latA/1000000) - Math.floor(latA/1000000)) * 60).toString();
			var tld = ( Math.floor(((((latA/1000000) - Math.floor(latA/1000000)) * 60) - Math.floor(((latA/1000000) - Math.floor(latA/1000000)) * 60)) * 100000) *60/100000 ).toString();
			ls = tls.toString();
			lm = tlm.toString();
			ld = tld.toString();

			if(ll.lng() < 0)
			{
		  		var tlgs = '-' + Math.floor((lonA / 1000000)).toString();
			}
			else
			{
				var tlgs = Math.floor((lonA / 1000000)).toString();
			}
			var tlgm = Math.floor(((lonA/1000000) - Math.floor(lonA/1000000)) * 60).toString();
			var tlgd = ( Math.floor(((((lonA/1000000) - Math.floor(lonA/1000000)) * 60) - Math.floor(((lonA/1000000) - Math.floor(lonA/1000000)) * 60)) * 100000) *60/100000 ).toString();
			lgs = tlgs.toString();
			lgm = tlgm.toString();
			lgd = tlgd.toString();
		}

		self.loadScript();
	}


	

	// window.onload = GMap.loadScript();

	return GMap;

});