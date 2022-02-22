txt: %.txt

%.txt:
	kdrfc --v3 draft-wkumari-dhc-addr-notification.md

pdf: %.pdf

%.pdf:
	kdrfc --v3 -P draft-wkumari-dhc-addr-notification.md


clean :
	rm -f *.txt *.xml
