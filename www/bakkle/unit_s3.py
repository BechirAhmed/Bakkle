import tinys3

config = {}
config['S3_BUCKET'] = 'com.bakkle.prod'
config['AWS_ACCESS_KEY'] = 'AKIAJIE2FPJIQGNZAMVQ' # server to s3
config['AWS_SECRET_KEY'] = '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'

config['AWS_ACCESS_KEY'] = 'AKIAJUCSHZSTNFVMEP3Q' # pethessa
config['AWS_SECRET_KEY'] = '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'

image_key = 'bob.jpg'
full_path = '/bakkle/www/img/0_ae10ae74d324dbda20e4be8feb723d48.jpg'
print("Storing {} to S3 bucket {} as {}".format(full_path, config['S3_BUCKET'], image_key))
conn = tinys3.Connection(config['AWS_ACCESS_KEY'], config['AWS_SECRET_KEY'],tls=True)
f = open(full_path,'rb')
print conn.upload('boxxb.jpg',f, 'com.bakkle.prod')
