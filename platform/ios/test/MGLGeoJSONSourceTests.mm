#import <XCTest/XCTest.h>

#import <Mapbox/Mapbox.h>
#import "MGLGeoJSONSource_Private.h"
#import "MGLSource_Private.h"

#include <mbgl/style/sources/geojson_source.hpp>

@interface MGLGeoJSONSourceTests : XCTestCase

@end

@implementation MGLGeoJSONSourceTests

- (void)testMGLGeoJSONSourceWithOptions {
    NSURL *url = [NSURL URLWithString:@"http://www.mapbox.com/source"];
    
    NSDictionary *options = @{MGLGeoJSONClusterOption: @(YES),
                              MGLGeoJSONClusterRadiusOption: @42,
                              MGLGeoJSONClusterMaximumZoomLevelOption: @98,
                              MGLGeoJSONMaximumZoomLevelOption: @99,
                              MGLGeoJSONBufferOption: @1976,
                              MGLGeoJSONToleranceOption: @0.42};
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"source-id" URL:url options:options];
    
    auto mbglOptions = [source geoJSONOptions];
    XCTAssertTrue(mbglOptions.cluster);
    XCTAssertEqual(mbglOptions.clusterRadius, 42);
    XCTAssertEqual(mbglOptions.clusterMaxZoom, 98);
    XCTAssertEqual(mbglOptions.maxzoom, 99);
    XCTAssertEqual(mbglOptions.buffer, 1976);
    XCTAssertEqual(mbglOptions.tolerance, 0.42);
  
    options = @{MGLGeoJSONClusterOption: @"number 1"};
    source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"source-id" URL:url options:options];
    XCTAssertThrows([source geoJSONOptions]);
}

- (void)testMGLGeoJSONSourceWithData {
    
    NSString *data = @"{\"type\": \"FeatureCollection\",\"features\": [{\"type\": \"Feature\",\"properties\": {},\"geometry\": {\"type\": \"LineString\",\"coordinates\": [[-107.75390625,40.329795743702064],[-104.34814453125,37.64903402157866]]}}]}";
    
    NSData *geoJSON = [data dataUsingEncoding:NSUTF8StringEncoding];
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"test-id" geoJSONData:geoJSON options:nil];
    
    [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolylineFeature class]]);
}

- (void)testMGLGeoJSONSourceWithPolylineFeatures {
    CLLocationCoordinate2D coordinates[] = { CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10)};
    MGLPolylineFeature *polylineFeature = [MGLPolylineFeature polylineWithCoordinates:coordinates count:2];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[polylineFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolylineFeature class]]);
}


- (void)testMGLGeoJSONSourceWithPolygonFeatures {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 0.0)};
    MGLPolygonFeature *polygonFeature = [MGLPolygonFeature polygonWithCoordinates:coordinates count:5];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[polygonFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolygonFeature class]]);
}

- (void)testMGLGeoJSONSourceWithPolygonFeaturesInculdingInteriorPolygons {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 0.0)};
    
    CLLocationCoordinate2D interiorCoordinates[] = {
        CLLocationCoordinate2DMake(100.2, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.2)};
    
    MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:interiorCoordinates count:5];
    
    MGLPolygonFeature *polygonFeature = [MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[polygonFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolygonFeature class]]);
}


- (void)testMGLGeoJSONSourceWithMultiPointFeaturesUsingPolylines {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0)};
    
    MGLMultiPointFeature *multiPointFeature = (MGLMultiPointFeature *)[MGLPolylineFeature polylineWithCoordinates:coordinates count:2];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[multiPointFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolylineFeature class]]);
}

- (void)testMGLGeoJSONSourceWithMultiPointFeaturesUsingPolygons {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 0.0)};
    
    CLLocationCoordinate2D interiorCoordinates[] = {
        CLLocationCoordinate2DMake(100.2, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.2)};
    
    MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:interiorCoordinates count:5];
    
    MGLMultiPointFeature *multiPointFeature = (MGLMultiPointFeature *)[MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[multiPointFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLPolygonFeature class]]);
}

- (void)testMGLGeoJSONSourceWithMultiPolylineFeatures {
    CLLocationCoordinate2D coordinates[] = { CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10)};
    MGLPolylineFeature *polylineFeature = [MGLPolylineFeature polylineWithCoordinates:coordinates count:2];
    CLLocationCoordinate2D coordinates_1[] = { CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10)};
    MGLPolylineFeature *polylineFeature_1 = [MGLPolylineFeature polylineWithCoordinates:coordinates_1 count:2];
    MGLMultiPolylineFeature *multiPolylineFeature = [MGLMultiPolylineFeature multiPolylineWithPolylines:@[polylineFeature, polylineFeature_1]];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[multiPolylineFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLMultiPolylineFeature class]]);
}

- (void)testMGLGeoJSONSourceWithMultiPolygonFeatures {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 0.0)};
    
    CLLocationCoordinate2D interiorCoordinates[] = {
        CLLocationCoordinate2DMake(100.2, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.2)};
    
    MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:interiorCoordinates count:5];
    
    MGLPolygonFeature *polygon_1 = [MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    MGLPolygonFeature *polygon_2 = [MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    
    MGLMultiPolygonFeature *multiPolygonFeature = [MGLMultiPolygonFeature multiPolygonWithPolygons:@[polygon_1, polygon_2]];
    
    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[multiPolygonFeature] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLMultiPolygonFeature class]]);

}

- (void)testMGLGeoJSONSourceWithShapeCollectionFeatures {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(100.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 0.0),
        CLLocationCoordinate2DMake(101.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 1.0),
        CLLocationCoordinate2DMake(100.0, 0.0)};
    
    CLLocationCoordinate2D interiorCoordinates[] = {
        CLLocationCoordinate2DMake(100.2, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.2),
        CLLocationCoordinate2DMake(100.8, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.8),
        CLLocationCoordinate2DMake(100.2, 0.2)};
    
    MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:interiorCoordinates count:5];
    
    MGLPolygonFeature *polygonFeature = [MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    
    CLLocationCoordinate2D coordinates_2[] = { CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10)};
    MGLPolylineFeature *polylineFeature = [MGLPolylineFeature polylineWithCoordinates:coordinates_2 count:2];
    
    MGLMultiPolygonFeature *multiPolygonFeature = [MGLMultiPolygonFeature multiPolygonWithPolygons:@[polygonFeature, polygonFeature]];
    
    MGLMultiPolylineFeature *multiPolylineFeature = [MGLMultiPolylineFeature multiPolylineWithPolylines:@[polylineFeature, polylineFeature]];
    
    MGLMultiPointFeature *multiPointFeature = (MGLMultiPointFeature *)[MGLPolygonFeature polygonWithCoordinates:coordinates count:5 interiorPolygons:@[polygon]];
    
    MGLPointFeature *pointFeature = [MGLPointFeature new];
    pointFeature.coordinate = CLLocationCoordinate2DMake(100.2, 0.2);
    
    MGLShapeCollectionFeature *shapeCollectionFeature = [MGLShapeCollectionFeature shapeCollectionWithShapes:@[polygonFeature, polylineFeature, multiPolygonFeature, multiPolylineFeature, multiPointFeature, pointFeature]];

    MGLShapeCollectionFeature *shapeCollectionFeature_1 = [MGLShapeCollectionFeature shapeCollectionWithShapes:@[polygonFeature, polylineFeature, multiPolygonFeature, multiPolylineFeature, multiPointFeature, pointFeature, shapeCollectionFeature]];

    MGLGeoJSONSource *source = [[MGLGeoJSONSource alloc] initWithSourceIdentifier:@"" features:@[shapeCollectionFeature_1] options:nil];
    
    std::unique_ptr<mbgl::style::Source> mbglSource = [source mbglSource];
    
    XCTAssertNotNil(source.features);
    XCTAssertEqual(source.features.count, 1);
    XCTAssertTrue([source.features.firstObject isMemberOfClass:[MGLShapeCollectionFeature class]]);
    
}

@end
