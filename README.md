# terraform-workshop


## Agenda

* Introduksjon
  * Hvordan funker Terraform
  * State-fil (eller lagre annet sted)
  * Resources
  * Varibler og referanser
  * Moduler
  * Provider (vi bruker AWS)
  * Provisioners


## Oppgave 1: Oppsett

Her skal vi sette opp Terraform for å bruke den med AWS.

Gå inn i AWS-konsollet, og generer en "Access Key" på brukeren din. Gå inn i
IAM, finn brukeren din under "Users", velg Security Credentials, og "Create
Access Key". Last ned fila, så du er sikker på å ikke miste keyene.

Hvis du bruker din egen konto, lag en bruker under "Users" først, og gi
brukeren nødvendig tilganger.

Neste steg er å sette opp miljøvariabler med Access Key-en, slik at Terraform
kan logge seg på AWS.  Dette gjøres ved å sette `AWS_ACCESS_KEY_ID` og
`AWS_SECRET_ACCESS_KEY`. Dette kan enten gjøres ved å legge det inn i
`.bashrc`, eller ved å kjøre export-kommandoene i shellet du bruker.

```bash
export AWS_ACCESS_KEY_ID="<din access key>"
export AWS_SECRET_ACCESS_KEY="<din secret key>"
```

## Oppgave 2: VPC

Vi begynner med å lage en [VPC i Terraform](https://www.terraform.io/docs/providers/aws/r/vpc.html).
Bruk `10.0.0.0/16` som `cidr_block`, og tag med ditt eget navn som `Name`, så
blir det lettere å vite hvem som eier hvilken VPC. Vi har en limit på 5 VPC-er
per region, så velg en region i USA eller Frankfurt (hvis du ikke bruker din
egen konto).

For å sjekke hvilke endringer Terraform har tenkt til å gjøre, kjør [`terraform
plan`](https://www.terraform.io/docs/commands/plan.html). Hvis alt ser riktig
ut, bruk [`terraform apply`](https://www.terraform.io/docs/commands/apply.html)
for å utfør endringene.


## Oppgave 3: Sett opp subnet

Nå skal vi sette opp to [subnet i
VPC-en](https://www.terraform.io/docs/providers/aws/r/subnet.html) vår. Husk å
sette `map_public_ip_on_launch` til true, så maskinene i subnettet får public
IP. Vi kommer bare til å kjøre to subnet i denne workshoppen, og ikke fire som
har gjort tidligere.

Pass også på å legge på en tag på subnettene, så du vet hvilke som er dine.

Ved å refere til
[VPC-en](https://www.terraform.io/docs/providers/aws/r/vpc.html) definert
tidligere, kan man hente ut ID-en, og bruke den når man definerer opp
subnettene. Id-en kan hentes ut med synaksen `${aws_vpc.navn.id}`. Se
[Interpolation](https://www.terraform.io/docs/configuration/interpolation.html)
for mer informasjon.


## Oppgave 4

Nå skal vi sette opp to webservere som kjører en webapp og en lastbalanserer
til å serve innholdet ut på internet. Istedenfor å kjøre opp serverene manuelt,
så lager vi en autoscalinggroup for serverene.

### Lastbalanserer

Vi begynner med å lage en lastbalanserer for webapplikasjonen.

### Sikkerhet

Siden vi har lyst til å logge inn på serverene for å sjekke at alt kom riktig
opp må vi lage et [Key
Pair](https://www.terraform.io/docs/providers/aws/r/key_pair.html) først.
Terraform støtter ikke å generere et nøkkelpar, så vi kan bruke kommandoen
`ssh-keygen -f terrform-workshop`. Innholdet i `terraform-workshop.pub` skal da
legges inn i feltet `public_key` i terraform-fila vår. Man kan enten kopiere
innholdet manuelt, eller bruke
[`file()`](https://www.terraform.io/docs/configuration/interpolation.html#element_list_index_)-funksjonen

Vi må også sette opp en Security Group for å kontrollere hvilke porter som er tilgjengelig.


### Launch configuration

An autoscaling group (AG) trenger en [Launch
Configuration](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
for å kunne vite hva slags type instancer som skal startes. `image_id` finner
man ved å logge inn på AWS-konsollet, og begynne å starte en EC2 instans i
regionen man bruker. Hver region har sine egne AMI-ider. Det kan også være en
god ide å sette
[create_bebfore_destroy](https://www.terraform.io/docs/configuration/resources.html#lifecycle)
til `true`, siden man ikke kan endre Launch Configuration. Da vil Terraform
lage en ny LC, oppdatere AG, og så lette den gamle LC igjen helt til slutt. På
den måten så får man ikke feil når man endrer Launch Configuration.
**NB!** Ikke glem å legg til keypair og Security group.


### Auto-scaling group

