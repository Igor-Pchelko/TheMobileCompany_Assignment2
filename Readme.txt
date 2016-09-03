Test app for http://themobilecompany.com/

Country Finder
--------------

Build an app that, based on a geolocation, tells the user in which country the location lies. The app has to work without Internet access. It has to show a map of the world, with some way of specifying a location. It has to show the country code or name of the country at that location. Try to optimize the app for speed (users do not like waiting) and keep an eye on memory usage (users do not like crashing apps). Your code should contain comments to clarify anything that you think needs clarification. Also, if you can, provide a written overview of your app and analysis of the problem and the software design decisions you made.

To help you get started, we provide a .kml Google Earth overlay file containing the geometry information of all the countries in the world. Your app should use this information to determine in which country a given geocoordinate is situated.

--------------
First of all, I would like to thank you for interesting tasks. It reminds me one of my project (Power Navigator for Symbian OS), in wich, we solve similar problems with projecting from GPS receiver (WGS 84) to custom users maps in various projections.

Here is several generic problems:
1. Rendering
2. Revers geolocation

I would say, my solution requires a lot of optimizations to become
a real candidate. However, it works on my iPhone 6 :-).. Following notes are about implementation and further improvements:

1. Rendering:
- I've decided to read data from json rather then parse KML, despite to apple provide the sample with KML parsing:
- KML sample from Apple: https://developer.apple.com/library/ios/samplecode/KMLViewer/Listings/Classes_KMLParser_m.html
- JSON source: https://raw.githubusercontent.com/datasets/geo-boundaries-world-110m/master/countries.geojson

- All rendering goes via Core Graphics in MapView drawRect. And MapView located in ScrollView. It could be optimized with occlusion culling visible part of vector map and rendering it directly via OpenGL stack..

2. Reverse geolocation:
The current implementation provides the naive algorithm that tests all polygons for specified location.  It could be optimized with implementing K-D tree algorithms:
https://www.cise.ufl.edu/class/cot5520fa09/CG_RangeKDtrees.pdf
https://github.com/Necrolis/GeoSharp



- Read KML:
https://developer.apple.com/library/ios/samplecode/KMLViewer/Listings/Classes_KMLParser_m.html

- JSON alternative:
https://raw.githubusercontent.com/datasets/geo-boundaries-world-110m/master/countries.geojson

- Draw map:
https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/BezierPaths/BezierPaths.html

Consider map projection:
- Mercator explanation: http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/

- Use occlusion culling to prevent drawing invisible poligons

- PNPoly to determinate point in non convex poligone
https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html

- Reverse Geocoding
https://github.com/Alterplay/APOfflineReverseGeocoding
https://github.com/krisrak/ios-offline-reverse-geocode-country

- K-D tree Geocoding
https://www.cise.ufl.edu/class/cot5520fa09/CG_RangeKDtrees.pdf
https://github.com/Necrolis/GeoSharp

My location:
 (latitude = 52.356154138489686, longitude = 4.6188812207081931)

