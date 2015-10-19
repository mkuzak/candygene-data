(function() {
  /* create chart objects */
  var elevationChart = dc.scatterPlot('#elevation-chart');
  var genebankSourceChart = dc.rowChart('#genebank-source-chart');
  var countryChart = dc.rowChart('#country-chart');
  var mapChart = dc.leafletMarkerChart('#map-chart');
  /* var speciesBubble = dc.bubbleCloud('#bubble-cloud'); */
  var dataTable = dc.dataTable('#data-table');

  /* load data */
  d3.csv('clean_potato.csv', function(error, data) {
    if (error) {
      porint(error);
    }

    /* format data */

    var dateFormat = d3.time.format('%m/%d/%Y');
    data.forEach(function(d) {
      d.gpsElevation = d.gpsElevation === 'NA' ? -1 : +d.gpsElevation;
      d.elevation = d.elevation === 'NA' ? -1 : +d.elevation;
      d.date = d.dateOfCollection === 'NA' ? dateFormat.parse('01/01/81') : dateFormat.parse(d.dateOfCollection);
      d.geo = d.gpsLat === 'NA' || d.gpsLon === 'NA' ? '-3.0,-79.0' : d.gpsLat.concat(',', d.gpsLon);
      d.genebankId = d.genebankId === 'NA' ? -1 : +d.genebankId;
    });

    /* crossfiler, dimensions and groups */
    var ndx = crossfilter(data);
    /* elevation */
    var elevationDim = ndx.dimension(function(d) {
      return [+d.gpsElevation, +d.elevation];
    });

    var elevationGroup = elevationDim.group();

    /* genebank source */
    var genebankSourceDim = ndx.dimension(function(d) {
      return d.genebank;
    });

    var genebankSourceGroup = genebankSourceDim.group();

    /* country of origin */
    var countryDim = ndx.dimension(function(d) {
      return d.country;
    });

    var countryGroup = countryDim.group();

    /* geolocation */
    var geoDim = ndx.dimension(function(d) {
      return d.geo;
    });

    var geoGroup = geoDim.group().reduceCount();

    /* bubble cloud
    // var speciesDim = ndx.dimension(function(d) {
    //   return d.species;
    // });
    // var speciesCount = speciesDim.group().reduceCount();
    //
    */

    /* data table */
    var genebankIDDim = ndx.dimension(function(d) {
      return d.genebankId;
    });

    /* elevation scatterplot */
    elevationChart
      .width(500)
      .height(500)
      .x(d3.scale.linear().domain([0, 5000]))
      .y(d3.scale.linear().domain([0, 5000]))
      .xAxisLabel('gps derived elevation')
      .yAxisLabel('original elevation')
      .symbolSize(4)
      .clipPadding(10)
      .dimension(elevationDim)
      .group(elevationGroup);

    /* genebank source chart */
    genebankSourceChart
      .width(400)
      .height(300)
      .group(genebankSourceGroup)
      .dimension(genebankSourceDim)
      .elasticX(true)
      .xAxis().ticks(5);

    /* country chart */
    countryChart
      .width(400)
      .height(300)
      .group(countryGroup)
      .dimension(countryDim)
      .elasticX(true)
      .xAxis().ticks(5);

    d3.select('#country-chart').on('dblclick', function() {
      countryChart.filter(null);
      countryChart.redrawGroup();
    });

    mapChart
      .width(500)
      .height(500)
      .dimension(geoDim)
      .group(geoGroup)
      .center([-3.0, -79.0])
      .cluster(true)
      .filterByArea(true)
      .brushOn(true)
      .renderPopup(false);

    // speciesBubble
    //   .width(500)
    //   .height(500)
    //   .dimension(speciesDim)
    //   .group(speciesCount)
    //   .x(d3.scale.ordinal())
    //   .r(d3.scale.linear())
    //   .radiusValueAccessor(function(d) {
    //     return d.value;
    //   });

    dataTable
      .dimension(genebankIDDim)
      .group(function(d) {
        return d.genebankId;
      })
      .columns([
        'genebankId', 'genebank', 'species', 'place', 'province', 'country',
        'gpsLon', 'gpsLat', 'gpsElevation', 'dateOfCollection',
      ])
      .size(data.length);

    dc.renderAll();
  });

})();
