#!/bin/bash
# Criado por: Rodrigo Floriano de Souza
# E-mail: florianocomercial@gmail.com
 
Principal() {
  echo ""
  echo "AWS Script - Escolha a opção desejada"
  echo "------------------------------------------"
  echo "Opções:"
  echo
  echo "1. describe-instances"
  echo "2. SSH Connect with terminator"
  echo "3. Criar novo bucket como website"
  echo "4. Criar novo bucket simples"
  echo "0. Sair"
  echo
  echo -n "Qual a opção desejada? "
  read opcao
  case $opcao in


        1)  describe-instances;;
	2)  ssh-multi-connect;;
	3)  create_s3_bucket-with-website;;
	4)  create_s3_bucket;;
        0) exit ;;
    *) "Opção desconhecida." ; echo ; Principal ;;
  esac
}

region-chooser() {
  echo ""
  echo "Escolha a região"
  echo "------------------------------------------"
  echo "Opções:"
  echo
  echo "0.  Sair"
  echo "1.  us-east-1      - US East (N. Virginia)"
  echo "2.  sa-east-1      - South America (São Paulo)"
  echo "3.  us-east-2      - US East (Ohio)"
  echo "4.  us-west-1      - US West (N. California)"
  echo "5.  us-west-2      - US West (Oregon)"
  echo "6.  eu-west-1      - EU (Ireland)"
  echo "7.  eu-central-1   - EU (Frankfurt)"
  echo "8.  ap-northeast-1 - Asia Pacific (Tokyo)"
  echo "9.  ap-northeast-2 - Asia Pacific (Seoul)"
  echo "10. ap-southeast-1 - Asia Pacific (Singapore)"
  echo "11. ap-southeast-2 - Asia Pacific (Sydney)"
  echo "12. ap-south-1     - Asia Pacific (Mumbai)"
  echo
  echo -n "Escolha a região que deseja listar as instâncias: "
  read region
  case $region in

	1)  REGION=us-east-1;;
	2)  REGION=sa-east-1;;
	3)  REGION=us-east-2;; 
	4)  REGION=us-west-1;;
	5)  REGION=us-west-2;;
	6)  REGION=eu-west-1;;
	7)  REGION=eu-central-1;;   
	8)  REGION=ap-northeast-1;; 
	9)  REGION=ap-northeast-2;; 
	10) REGION=ap-southeast-1;; 
	11) REGION=ap-southeast-2;; 
	12) REGION=ap-south-1;;
   	0) exit ;;
    *) "Opção desconhecida." ; echo $REGION ; describe-instances ;;
  esac
}

search-tagname() {
        echo ""
        echo -n "Insira um valor respectivo a TAG NAME da instância, pode-se utilizar * como coringa: "
        read TAG_NAME

}

describe-instances() {	
	region-chooser
	search-tagname
	echo ""
	echo "============================================================"
	echo "= Listando as instâncias AWS - $REGION - TAGNAME=$TAG_NAME ="
	echo "============================================================"
	aws ec2 describe-instances --region $REGION --filter --filter Name=tag:Name,Values=$TAG_NAME |grep PublicDnsName |awk -F '"' '{print $4}' |sort |uniq
	echo "============================================================"
}

ssh-multi-connect() {

	eval $(ssh-agent -s) >/dev/null 2>&1
        region-chooser
        search-tagname
	
	echo -n "Digite o nome do usuario: "
	read USER

	LISTA=/tmp/aws-host-list.txt
	#USER=rodrigo.souza
	TERMCONFIG=/root/.config/terminator/config
	source /etc/profile

	aws ec2 describe-instances --region $REGION --filter --filter Name=tag:Name,Values=$TAG_NAME* |grep PublicDnsName |awk -F '"' '{print $4}' |sort |uniq  >  $LISTA

	sed -ri '1s/^/host1=/;2s/^/host2=/;3s/^/host3=/;4s/^/host4=/;5s/^/host5=/;6s/^/host6=/' $LISTA

	source $LISTA

	sed -ri '/command/d' $TERMCONFIG

	sed -ri "/terminal5/a  \ \ \ \ \ \ command = ssh $USER@$host1" $TERMCONFIG
	sed -ri "/terminal6/a  \ \ \ \ \ \ command = ssh $USER@$host2" $TERMCONFIG
	sed -ri "/terminal7/a  \ \ \ \ \ \ command = ssh $USER@$host3" $TERMCONFIG
	sed -ri "/terminal8/a  \ \ \ \ \ \ command = ssh $USER@$host4" $TERMCONFIG
	sed -ri "/terminal9/a  \ \ \ \ \ \ command = ssh $USER@$host5" $TERMCONFIG
	sed -ri "/terminal10/a  \ \ \ \ \ \ command = ssh $USER@$host6" $TERMCONFIG

	terminator -l six-terminals

	rm -f $LISTA
	sed -ri '/command/d' $TERMCONFIG
	exit 0

}

create_s3_bucket-with-website() {
        echo ""
        echo -n "Insira o nome do Bucket: "
        read BUCKET_NAME
	aws s3 mb s3://$BUCKET_NAME
	aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html
	exit 0
}

create_s3_bucket() {
        echo ""
        echo -n "Insira o nome do Bucket: "
        read BUCKET_NAME
        aws s3 mb s3://$BUCKET_NAME
        exit 0
}

Principal 
