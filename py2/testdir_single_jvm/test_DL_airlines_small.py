import unittest, time, sys, random, string
sys.path.extend(['.','..','../..','py'])
import h2o, h2o_cmd, h2o_import as h2i, h2o_jobs
from h2o_test import verboseprint, dump_json, OutputObj

class Basic(unittest.TestCase):
    def tearDown(self):
        h2o.check_sandbox_for_errors()

    @classmethod
    def setUpClass(cls):
        global SEED
        SEED = h2o.setup_random_seed()
        h2o.init()

    @classmethod
    def tearDownClass(cls):
        h2o.tear_down_cloud()

    def test_DL_covtype(self):
        csvPathname_train = 'airlines/AirlinesTrain.csv.zip'
        csvPathname_test  = 'airlines/AirlinesTest.csv.zip'
        hex_key = 'train.hex'
        validation_key = 'validation.hex'
        timeoutSecs = 60
        parseResult  = h2i.import_parse(bucket='smalldata', path=csvPathname_train, hex_key=hex_key, timeoutSecs=timeoutSecs, doSummary=False)
        numRows, numCols, parse_key = h2o_cmd.infoFromParse(parseResult)
        inspectResult = h2o_cmd.runInspect(key=parse_key)
        missingList, labelList, numRows, numCols = h2o_cmd.infoFromInspect(inspectResult)

        parseResultV = h2i.import_parse(bucket='smalldata', path=csvPathname_test, hex_key=validation_key, timeoutSecs=timeoutSecs, doSummary=False)
        numRowsV, numColsV, parse_keyV = h2o_cmd.infoFromParse(parseResultV)
        inspectResultV = h2o_cmd.runInspect(key=parse_keyV)
        missingListV, labelListV, numRowsV, numColsV = h2o_cmd.infoFromInspect(inspectResultV)

        #Making random id
        identifier = ''.join(random.sample(string.ascii_lowercase + string.digits, 10))
        model_key = 'deeplearning_' + identifier + '.hex'

        parameters = {
            'validation_frame': validation_key, # KeyIndexed None
            'ignored_columns': '["IsDepDelayed_REC"]', # string[] None
            'score_each_iteration': None, # boolean false
            'response_column': 'IsDepDelayed', # string None
            'do_classification': True, # boolean false
            'loss': 'CrossEntropy'
        }
        expectedErr = 0.27 ## expected validation error for the above model
        relTol = 0.15 ## 15% rel. error tolerance due to Hogwild!

        timeoutSecs = 60
        start = time.time()

        bmResult = h2o.n0.build_model(
            algo='deeplearning',
            destination_key=model_key,
            training_frame=hex_key,
            parameters=parameters,
            timeoutSecs=timeoutSecs)
        bm = OutputObj(bmResult, 'bm')

        print 'deep learning took', time.time() - start, 'seconds'

        cmmResult = h2o.n0.compute_model_metrics(model=model_key, frame=validation_key, timeoutSecs=60)
        cmm = OutputObj(cmmResult, 'cmm')

        mmResult = h2o.n0.model_metrics(model=model_key, frame=validation_key, timeoutSecs=60)
        mm = OutputObj(mmResult['model_metrics'][0], 'mm')

        prResult = h2o.n0.predict(model=model_key, frame=validation_key, timeoutSecs=60)
        pr = OutputObj(prResult['model_metrics'][0]['predictions'], 'pr')

        h2o_cmd.runStoreView()

        print "expected classification error: " + format(expectedErr)

        print "==============================="
        print "==============================="
        print "==============================="
        print "TODO: COMPARE WITH ACTUAL ERROR"
        print "==============================="
        print "==============================="
        print "==============================="

#        actualErr = ...
#        print "actual   classification error: " + format(actualErr)

#        if actualErr != expectedErr and abs((expectedErr - actualErr)/expectedErr) > relTol:
#            raise Exception("Scored classification error of %s is not within %s %% relative error of %s" %
#                            (actualErr, float(relTol)*100, expectedErr))


if __name__ == '__main__':
    h2o.unit_main()
