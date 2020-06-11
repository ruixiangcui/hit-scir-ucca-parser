.PHONY: ewt ewt.mrp ud streusle companion augment split clean

../toolkit/mtool:
	git clone https://github.com/cfmrp/mtool $@

ewt:
	git clone https://github.com/UniversalConceptualCognitiveAnnotation/UCCA_English-EWT -b v1.0-sentences ewt

ewt.mrp:
	wget -qO- http://svn.nlpl.eu/mrp/2019/public/ucca.tgz?p=28375 | tar xvz
	cp mrp/2019/training/ucca/ewt.mrp ./

ud: en_ewt-ud.conllu en_ewt-ud-train.conllu en_ewt-ud-dev.conllu en_ewt-ud-test.conllu

en_ewt-ud-train.conllu en_ewt-ud-dev.conllu en_ewt-ud-test.conllu:
	git clone https://github.com/UniversalDependencies/UD_English-EWT --branch=r2.5 ud
	cp ud/*.conllu ./

en_ewt-ud.conllu: en_ewt-ud-train.conllu en_ewt-ud-dev.conllu en_ewt-ud-test.conllu
	cat $+ > $@

streusle: streusle.conllulex streusle.ud_train.conllulex streusle.ud_dev.conllulex streusle.ud_test.conllulex

streusle.conllulex streusle.ud_train.conllulex streusle.ud_dev.conllulex streusle.ud_test.conllulex:
	git clone https://github.com/nert-nlp/streusle --branch=v4.3
	cp streusle/streusle.conllulex streusle/*/streusle.ud_*.conllulex ./

companion: ewt.companion.conllu

ewt.companion.conllu:
	wget -qO- http://svn.nlpl.eu/mrp/2019/public/companion.tgz?p=28375 | tar xvz
	cat mrp/2019/companion/ucca/ewt0*.conllu > $@

augment: ewt.aug.companion.mrp ewt.aug.streusle.mrp

ewt.aug.companion.mrp: ewt.companion.conllu ewt.mrp
	python ../toolkit/augment_data_conllu.py $+ $@

ewt.aug.streusle.mrp: streusle.conllulex ewt.mrp ewt.aug.streusle.mrp
	python ../toolkit/augment_data_conllulex.py $+ $@

split: ewt/train ewt/dev ewt/test \
       ewt.train.aug.streusle.mrp ewt.dev.aug.streusle.mrp ewt.test.aug.companion.mrp \
       ewt.train.aug.companion.mrp ewt.dev.aug.companion.mrp ewt.test.aug.streusle.mrp

ewt/%: ../file-lists/%.txt
	mkdir -p $@
	xargs -I % find ewt -maxdepth 1 -name '%*.pickle' < $< | xargs ln -srt $@

ewt.%.aug.streusle.mrp: ../file-lists/%.txt
	grep -Ff $< ewt.aug.streusle.mrp > $@

ewt.%.aug.companion.mrp: ../file-lists/%.txt
	grep -Ff $< ewt.aug.companion.mrp > $@

clean:
	rm -rf mrp ewt ud streusle *.mrp *.conllu *.conllulex
