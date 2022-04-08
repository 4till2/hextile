module Services
  class ArcgisParser

    MILE_MARKER_REMOTE_URL = 'https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/PCTA_Mile_Marker_2022/FeatureServer/0/query?where=Mile+between+0+and+5000&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=standard&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=Mile&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='.freeze
    # https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/Permit_Areas_Public/FeatureServer/0
    PERMIT_AREAS_REMOTE_URL = 'https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/Permit_Areas_Public/FeatureServer/0/query?where=OBJECTID+between+0+and+10000&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_StatuteMile&returnGeodetic=false&outFields=Agency%2C+Permit_Area_Name%2C+State%2C+Direct_Managing_Authority%2C+Miles_of_PCT%2C+PCTA_Region%2C+Wilderness_Y_N%2C+Permit_required_on_PCT__Y_N%2C+Agency_Sub_Unit%2C+Permit_situation_summary%2C+Quota%2C+Permit_but_not_on_PCT%2C+Permit__but_not_really_required%2C+Website%2C+Shape__Area%2C+Shape__Length%2C+Second_Website&returnGeometry=true&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='.freeze
    # https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/PCTA_Centerline/FeatureServer/0/
    CENTER_LINE_REMOTE_URL = 'https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/PCTA_Centerline/FeatureServer/0/query?where=OBJECTID+between+0+and+10000+&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='.freeze
    # https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/Trail_Town_Resupply_Public/FeatureServer/0
    TOWN_RESUPPLY_REMOTE_URL = 'https://services5.arcgis.com/ZldHa25efPFpMmfB/ArcGIS/rest/services/Trail_Town_Resupply_Public/FeatureServer/0/query?where=OBJECTID+between+0+and+10000+&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=Location%2C+State%2C+F_Town_%2C+Generally_only_businesses&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='.freeze

    def mile_markers
      @mile_markers ||= _mile_markers
    end

    def permit_areas
      @permit_areas ||= _permit_areas
    end

    def center_line
      @center_line ||= _center_line
    end

    def town_resupply
      @town_resupply ||= _town_resupply
    end

    private

    def _center_line
      fetch(CENTER_LINE_REMOTE_URL)
    end

    def _mile_markers
      fetch(MILE_MARKER_REMOTE_URL)
    end

    def _permit_areas
      fetch(PERMIT_AREAS_REMOTE_URL)
    end

    def _town_resupply
      fetch(TOWN_RESUPPLY_REMOTE_URL)
    end

    def fetch(url)
      HTTParty.get(url)
    end
  end
end
