.PHONY: wwm_cased_L-24_H-1024_A-16 clean

wwm_cased_L-24_H-1024_A-16:
	wget https://storage.googleapis.com/bert_models/2019_05_30/wwm_cased_L-24_H-1024_A-16.zip
	unzip wwm_cased_L-24_H-1024_A-16.zip
	wget https://s3.amazonaws.com/models.huggingface.co/bert/bert-large-cased-pytorch_model.bin
	mv bert-large-cased-pytorch_model.bin wwm_cased_L-24_H-1024_A-16/pytorch_model.bin

clean:
	rm -rf wwm_cased_L-24_H-1024_A-16
