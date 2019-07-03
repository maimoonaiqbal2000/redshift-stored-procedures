import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

print ("Starting ETL Job")
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

print ("Table EOD price")
dataSourceEodPrice = glueContext.create_dynamic_frame.from_catalog(database = "oltp_uploads", table_name = "eod_price_csv", transformation_ctx = "dataSourceEodPrice")
print "Count EodPrice:",dataSourceEodPrice.count()
print "Schema of EodPrice frame:"
dataSourceEodPrice.printSchema()
dataSourceEodPrice.toDF().show()

applyMappingEodPrice = ApplyMapping.apply(frame = dataSourceEodPrice, mappings = [("symbol", "string", "symbol", "string"), ("eod_date", "string", "eod_date", "date"), ("open_price", "double", "open_price", "double"), ("high_price", "double", "high_price", "double"), ("low_price", "double", "low_price", "double"), ("eod_price", "double", "eod_price", "double"), ("volume", "long", "volume", "double")], transformation_ctx = "applyMappingEodPrice")
print "Count EodPriceMapping:",applyMappingEodPrice.count()
print "Schema of EodPriceMapping frame:"
applyMappingEodPrice.printSchema()
applyMappingEodPrice.toDF().show()

print ("Table Industry")
dataSourceIndustry = glueContext.create_dynamic_frame.from_catalog(database = "oltp_uploads", table_name = "industry_csv", transformation_ctx = "dataSourceIndustry")
applyMappingIndustry = ApplyMapping.apply(frame = dataSourceIndustry, mappings = [("industryid", "long", "industryid", "int"), ("industry_name", "string", "industry_name", "string")], transformation_ctx = "applyMappingIndustry")
print "Count Industry:",applyMappingIndustry.count()
print "Schema of Industry frame:"
applyMappingIndustry.printSchema()


print ("Table Sector")
dataSourceSector = glueContext.create_dynamic_frame.from_catalog(database = "oltp_uploads", table_name = "sector_csv", transformation_ctx = "dataSourceSector")
applyMappingSector = ApplyMapping.apply(frame = dataSourceSector, mappings = [("sectorid", "long", "sectorid", "int"), ("sector_name", "string", "sector_name", "string")], transformation_ctx = "applyMappingSector")
print "Count Sector:",applyMappingSector.count()
print "Schema of Sector frame:"
applyMappingSector.printSchema()


print ("Table Security")
dataSourceSecurity = glueContext.create_dynamic_frame.from_catalog(database = "oltp_uploads", table_name = "security_csv", transformation_ctx = "dataSourceSecurity")
print "Count Security:",dataSourceSecurity.count()
print "Schema of Security frame:"
dataSourceSecurity.printSchema()
dataSourceSecurity.toDF().show()


applyMappingSecurity = ApplyMapping.apply(frame = dataSourceSecurity, mappings = [("securityid", "long", "securityid", "int"), ("symbol", "string", "symbol", "string"), ("lastsale", "double", "lastsale", "double"), ("marketcap", "bigint", "marketcap", "bigint"), ("ipoyear", "long", "ipoyear", "int"), ("sectorid", "long", "sectorid", "int"), ("industryid", "long", "industryid", "int"), ("name", "string", "security_name", "string")], transformation_ctx = "applyMappingSecurity")
print "Count SecurityMapping:",applyMappingSecurity.count()
print "Schema of SecurityMapping frame:"
applyMappingSecurity.printSchema()
applyMappingSecurity.toDF().show()

print ("Join Security Sector ")
joinSecuritySector = Join.apply(frame1 = dataSourceSector, frame2 = dataSourceSecurity, keys1 = 'sectorid', keys2 = 'sectorid', transformation_ctx = 'joinSecuritySector')
print "Count after joinSecuritySector:",joinSecuritySector.count()
print "Schema of joinSecuritySector frame:"
joinSecuritySector.printSchema()


print ("Join Industry")
joinSecuritySectorIndustry = Join.apply(frame1 = dataSourceIndustry, frame2 = joinSecuritySector, keys1 = 'industryid', keys2 = 'industryid', transformation_ctx = 'joinSecuritySectorIndustry')
print "Count after joinSecuritySectorIndustry:",joinSecuritySectorIndustry.count()
print "Schema of joinSecuritySectorIndustry frame:"
joinSecuritySectorIndustry.printSchema()


print ("Join All Tables")
joinAllTables = Join.apply(frame1 = dataSourceEodPrice, frame2 = joinSecuritySectorIndustry, keys1 = 'symbol', keys2 = 'symbol', transformation_ctx = 'joinAllTables')
print "Count after joinAllTables:",joinAllTables.count()
print "Schema of joinAllTables frame:"
joinAllTables.printSchema()

print ("Redshift Catalog Mapping")
applyMapping = ApplyMapping.apply(frame = joinAllTables, mappings = [("symbol", "string", "symbol", "string"), ("marketcap", "bigint", "marketcap", "bigint"), ("industry_name", "string", "industry_name", "string"), ("sectorid", "long", "sectorid", "int"), ("high_price", "double", "high_price", "double"), ("eod_price", "double", "eod_price", "double"), ("securityid", "long", "securityid", "int"), ("eod_date", "string", "eod_date", "date"), ("lastsale", "double", "lastsale", "double"), ("security_name", "string", "security_name", "string"), ("volume", "string", "volume", "double"), ("industryid", "long", "industryid", "int"), ("sector_name", "string", "sector_name", "string"), ("open_price", "double", "open_price", "double"), ("low_price", "double", "low_price", "double"), ("ipoyear", "long", "ipoyear", "int")], transformation_ctx = "applyMapping")
selectFields = SelectFields.apply(frame = applyMapping, paths = ["symbol", "marketcap", "industry_name", "sectorid", "ipoyear", "high_price", "eod_price", "securityid", "eod_date", "lastsale", "security_name", "volume", "industryid", "sector_name", "open_price", "low_price"], transformation_ctx = "selectFields")
print "Count after SelectFields:",selectFields.count()
print "Schema of SelectFields frame:"
selectFields.printSchema()
selectFields.toDF().show()


resolveChoiceRedshiftCatalog = ResolveChoice.apply(frame = selectFields, choice = "MATCH_CATALOG", database = "redshift_olap_database", table_name = "manash_olap_market_data", transformation_ctx = "resolveChoiceRedshiftCatalog")
resolveChoiceRedshiftColumns = ResolveChoice.apply(frame = resolveChoiceRedshiftCatalog, choice = "make_cols", transformation_ctx = "resolveChoiceRedshiftColumns")
print "Count after resolveChoiceRedshiftColumns:",resolveChoiceRedshiftColumns.count()
print "Schema of resolveChoiceRedshiftColumns frame:"
resolveChoiceRedshiftColumns.printSchema()
resolveChoiceRedshiftColumns.toDF().show()

print ("Write to Redshift")
dataSinkRedshiftFinal = glueContext.write_dynamic_frame.from_catalog(frame = resolveChoiceRedshiftColumns, database = "redshift_olap_database", table_name = "manash_olap_market_data", redshift_tmp_dir = args["TempDir"], transformation_ctx = "dataSinkRedshiftFinal")

print ("Job Commit")
job.commit()
