local metaDefs = {}
metaDefs[#metaDefs + 1] = { id='lastUpdate', title='ExifMeta Updated', version=1, dataType='string', searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='lastUpdate_' }

metaDefs[#metaDefs + 1] = { id='bigBlock', title='Exif Metadata', version=2, dataType='string', readOnly=false, searchable=false, browsable=false }
metaDefs[#metaDefs + 1] = { id='Composite_GPSAltitude', title='GPS Altitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='Composite_GPSDateTime', title='GPS Date/Time', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='Composite_GPSLatitude', title='GPS Latitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='Composite_GPSLongitude', title='GPS Longitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='Composite_GPSPosition', title='GPS Position', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSAltitude', title='GPS Altitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSAltitudeRef', title='GPS Altitude Ref', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSDateStamp', title='GPS Date Stamp', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSLatitude', title='GPS Latitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSLatitudeRef', title='GPS Latitude Ref', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSLongitude', title='GPS Longitude', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSLongitudeRef', title='GPS Longitude Ref', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSMapDatum', title='GPS Map Datum', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSSatellites', title='GPS Satellites', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSTimeStamp', title='GPS Time Stamp', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }
metaDefs[#metaDefs + 1] = { id='GPS_GPSVersionID', title='GPS Version ID', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }

return {
  metadataFieldsForPhotos = metaDefs,
  schemaVersion = 1,
}