build: .lastbuild
	
.lastbuild: Dockerfile main.py params.py auth.py routers/public.py routers/secure.py
	docker build -t ${image_name} .  && touch .lastbuild

push: .lastpush

.lastpush: .lastbuild .lasttag
	docker push ${artifact_image_name}  && touch .lastpush

tag: .lasttag

.lasttag: 
	docker tag ${image_name} ${artifact_image_name} && touch .lasttag

clean:
	rm -f .lastpush .lastbuild .lasttag