<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:l="http://local.data" xmlns:pqfn="http://local/functions" xmlns:ext="http://exslt.org/common" xmlns:dyn="http://exslt.org/dynamic" xmlns:date="http://exslt.org/dates-and-times" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="dyn l pqfn exsl" extension-element-prefixes="dyn date ext xs exsl" version="1.0">
	<xsl:import href="../../../utils/utils.xsl" />
	<xsl:output method="xml"/>

	<!-- Variables -->

	<!-- NOTE: When passing in a string instead of an xpath, it needs to be
	wrapped in a nodeset: as follows: ext:node-set('CH') -->

	<!-- To add to the ingest record template, you need to define new variable and
	then if needed, a new template, then call the template in the IngestRecord
	block -->

	<xsl:variable name="platformorigin" select="ext:node-set('CH')" />
	<xsl:variable name="productorigin" select="'archives'" />
	<xsl:variable name="originalid" select=".//recid" />
	<xsl:variable name="prefixid">
		<xsl:value-of select="$productorigin" />-<xsl:value-of select="$originalid" />
	</xsl:variable>
	<xsl:variable name="isbn" select="blank" />
	<xsl:variable name="shelfmark" select="blank" />
	<xsl:variable name="mfnosrch" select="blank" />
	<xsl:variable name="pubid" select=".//product" />
	<xsl:variable name="sourcetype" select="'Archival Materials'" />
	<xsl:variable name="title" select=".//rec/collname" />
	<xsl:variable name="alternatetitle" select="blank" />
	<xsl:variable name="numericdate" select=".//rec/year1" />
	<xsl:variable name="displaydate" select=".//rec/date1" />
	<xsl:variable name="numericenddate" select=".//rec/year2" />
	<xsl:variable name="numericstartdate" select="$numericdate" />
	<xsl:variable name="language" select="blank" />
	<xsl:variable name="copyrightdata" select="blank" />
	<xsl:variable name="startpage" select="blank" />
	<xsl:variable name="pagination" select="blank" />
	<xsl:variable name="objecttype" select="'Archival Collection'" />
	<xsl:variable name="accnum" select=".//rec/lcn" />
	<xsl:variable name="fichenumber" select=".//rec/fiche" />
	<xsl:variable name="nucmcnumber" select=".//rec/nucmcno" />
	<xsl:variable name="abstract" select=".//rec/desc" />
	<xsl:variable name="dpmi" select="blank" />
	<xsl:variable name="dpmicount" select="blank" />
	<xsl:variable name="pdf" select="blank" />
	<xsl:variable name="pdfbytes" select="blank" />
	<xsl:variable name="keyedfulltext" select="blank" />
	<xsl:variable name="toc" select="blank" />
	<xsl:variable name="documentnote" select=".//rec/notes" />
	<xsl:variable name="physdescnote" select=".//rec/extent" />
	<xsl:variable name="collurl" select=".//rec/findaid/url" />
	<xsl:variable name="typecoll" select=".//rec/type" />
	<xsl:variable name="mfextent" select="blank" />
	<xsl:variable name="pubnote" select="blank" />
	<xsl:variable name="physdesc" select="blank" />
	<xsl:variable name="column" select="blank" />
	<xsl:variable name="pubtitle" select="blank" />
	<xsl:variable name="volume" select="blank" />
	<xsl:variable name="issue" select="blank" />
	<xsl:variable name="nucmcsubj" select=".//rec/nucmcterm" />
	<xsl:variable name="nidsubj" select=".//rec/nidsterm" />
	<xsl:variable name="personalSubject" select="blank" />
	<xsl:variable name="geographicSubject" select="blank" />
	<xsl:variable name="companySubject" select="blank" />
	<xsl:variable name="location" select="blank" />
	<xsl:variable name="ncssubj" select="blank" />
	<xsl:variable name="publisherorg" select="blank" />
	<xsl:variable name="publishercity" select="blank" />
	<xsl:variable name="publicationseries" select="blank" />
	<xsl:variable name="publicationimprint" select="blank" />
	<xsl:variable name="docfeatures" select="blank" />
	<xsl:variable name="simpleauthor" select="blank" />
	<xsl:variable name="birthdate" select="blank" />
	<xsl:variable name="deathdate" select="blank" />
	<xsl:variable name="epithet" select="blank" />
	<xsl:variable name="sourceinstitution" select=".//rec/rname" />
	<xsl:variable name="repositoryinfo" select=".//rec/repository" />
	<xsl:variable name="country" select=".//rec/country" />
	<xsl:variable name="nstcnumber" select="blank" />

	<!-- Element templates -->

	<xsl:template name="SourceType">
		<SourceType>
			<xsl:attribute name="SourceTypeOrigin"><xsl:value-of select="$platformorigin" /></xsl:attribute>
			<xsl:value-of select="$sourcetype" />
		</SourceType>
	</xsl:template>

	<xsl:template name="ObjectType">
		<ObjectType>
			<xsl:attribute name="ObjectTypeOrigin"><xsl:value-of select="$platformorigin" /></xsl:attribute>
			<xsl:value-of select="$objecttype" />
		</ObjectType>
	</xsl:template>

	<xsl:template name="Title">
		<Title><xsl:value-of select="$title" /></Title>
	</xsl:template>

	<xsl:template name="AlternateTitle">
		<xsl:for-each select="ext:node-set($alternatetitle)">
			<AlternateTitle><xsl:value-of select="." /></AlternateTitle>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="ObjectNumericDate">
		<ObjectNumericDate>
			<xsl:choose>
				<!-- Consider how to handle dates with less than 3 digits -->
				<xsl:when test="$numericdate">
					<xsl:value-of select="$numericdate" />
					<xsl:text>0101</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="Undated">true</xsl:attribute>
					<xsl:text>00010101</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</ObjectNumericDate>
	</xsl:template>

	<xsl:template name="ObjectEndDate">
		<xsl:if test="$numericenddate">
			<ObjectEndDate>
				<xsl:value-of select="$numericenddate" />
				<xsl:text>0101</xsl:text>
			</ObjectEndDate>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ObjectStartDate">
		<xsl:if test="$numericstartdate">
			<ObjectStartDate>
				<xsl:value-of select="$numericstartdate" />
				<xsl:text>0101</xsl:text>
			</ObjectStartDate>
		</xsl:if>
	</xsl:template>

	<!-- <xsl:template name="ObjectEndDate">
		<xsl:if test="$numericenddate">
			<ObjectEndDate>
				<xsl:value-of select="$numericenddate" />
			</ObjectEndDate>
		</xsl:if>
	</xsl:template> -->

	<xsl:template name="DisplayDate">
		<xsl:choose>
			<xsl:when test="$displaydate">
				<ObjectRawAlphaDate><xsl:value-of select="$displaydate" /></ObjectRawAlphaDate>
			</xsl:when>
			<xsl:otherwise>
				<ObjectAlphaDate>
					<xsl:attribute name="Undated">true</xsl:attribute>
					<xsl:text>Jan 1, 1</xsl:text>
				</ObjectAlphaDate>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="Language">
		<Language>
			<RawLang>
				<xsl:call-template name="match_or_default">
					<xsl:with-param name="match_field" select="$language" />
					<xsl:with-param name="default_value" select="'English'" />
				</xsl:call-template>
			</RawLang>
		</Language>
	</xsl:template>

	<xsl:template name="CopyrightData">
		<xsl:if test="$copyrightdata">
			<Copyright>
				<CopyrightData HTMLContent="true">
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
					<xsl:value-of select="$copyrightdata" />
					<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
				</CopyrightData>
			</Copyright>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PrintLocation">
		<xsl:if test="$startpage or $pagination or $column">
			<PrintLocation>
				<xsl:call-template name="StartPage" />
				<xsl:call-template name="Pagination" />
				<xsl:call-template name="ColumnNumber" />
			</PrintLocation>
		</xsl:if>
	</xsl:template>

	<xsl:template name="StartPage">
		<xsl:if test="$startpage">
			<StartPage>
				<xsl:value-of select="$startpage" />
			</StartPage>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Pagination">
		<xsl:if test="$pagination">
			<Pagination>
				<xsl:value-of select="$pagination" />
			</Pagination>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ColumnNumber">
		<xsl:if test="$column">
			<ColumnNumber>
				<xsl:value-of select="$column" />
			</ColumnNumber>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ObjectIDs">
		<ObjectIDs>
			<xsl:if test="$isbn">
				<ObjectID IDType="DocISBN">
					<xsl:value-of select="$isbn" />
				</ObjectID>
			</xsl:if>
			<ObjectID IDType="CHLegacyID" IDOrigin="CH">
				<xsl:value-of select="$prefixid" />
			</ObjectID>
			<ObjectID IDType="CHOriginalLegacyID" IDOrigin="CH">
				<xsl:value-of select="$originalid" />
			</ObjectID>
			<xsl:if test="$shelfmark">
				<ObjectID IDType="Shelfmark" IDOrigin="CH">
					<xsl:value-of select="$shelfmark" />
				</ObjectID>
			</xsl:if>
			<xsl:if test="$accnum">
				<ObjectID IDType="AccNum" IDOrigin="CH">
					<xsl:value-of select="$accnum" />
				</ObjectID>
			</xsl:if>
			<xsl:if test="$nstcnumber">
				<ObjectID IDType="NSTCNumber" IDOrigin="CH">
					<xsl:value-of select="$nstcnumber" />
				</ObjectID>
			</xsl:if>
			<xsl:if test="$fichenumber">
				<ObjectID IDType="FicheNum" IDOrigin="CH">
					<xsl:value-of select="$fichenumber" />
				</ObjectID>
			</xsl:if>
			<xsl:if test="$nucmcnumber">
				<ObjectID IDType="NUCMC" IDOrigin="CH">
					<xsl:value-of select="$nucmcnumber" />
				</ObjectID>
			</xsl:if>
		</ObjectIDs>
	</xsl:template>

	<xsl:template name="ComponentAbstract">
		<xsl:if test="$abstract">
			<Component ComponentType="Abstract">
				<Representation RepresentationType="Abstract">
					<MimeType>text/xml</MimeType>
					<Resides>FAST</Resides>
				</Representation>
			</Component>
		</xsl:if>
    </xsl:template>

	<xsl:template name="DisplayAbstract">
		<xsl:if test="$abstract">
			<Abstract>
				<xsl:attribute name="AbstractType">Summary</xsl:attribute>
				<AbsText HTMLContent="true">
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
					<xsl:apply-templates select="$abstract" />
					<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
				</AbsText>
			</Abstract>
		</xsl:if>
    </xsl:template>

	<xsl:template name="Contributors">
		<xsl:if test="$simpleauthor or $sourceinstitution">
			<Contributors>
				<!-- <xsl:call-template name="Contributor" /> -->
				<xsl:call-template name="SourceInstitution" />
			</Contributors>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Contributor">
		<xsl:for-each select="$simpleauthor">
			<Contributor  ContribRole="Author">
				<xsl:attribute name="ContribOrder"><xsl:value-of select="position()" /></xsl:attribute>
					<OriginalForm>
						<xsl:value-of select="." />
					</OriginalForm>
				<xsl:call-template name="BirthDate" />
				<xsl:call-template name="DeathDate" />
				<xsl:call-template name="ContribDesc" />
			</Contributor>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="SourceInstitution">
		<xsl:for-each select="$sourceinstitution">
			<Contributor>
				<xsl:attribute name="DoNotNormalize"><xsl:value-of select="'Y'"/></xsl:attribute>
				<xsl:attribute name="ContribRole">SourceInstitution</xsl:attribute>
				<xsl:attribute name="ContribOrder"><xsl:value-of select="position()" /></xsl:attribute>
					<LastName><xsl:value-of select="." /></LastName>
					<xsl:if test="ext:node-set($repositoryinfo)/city">
						<City><xsl:value-of select="ext:node-set($repositoryinfo)/city"/></City>
					</xsl:if>
					<xsl:if test="ext:node-set($repositoryinfo)/statefull">
						<StateProvince><xsl:value-of select="ext:node-set($repositoryinfo)/statefull"/></StateProvince>
					</xsl:if>
					<xsl:if test="ext:node-set($repositoryinfo)/county">
						<StateProvince><xsl:value-of select="ext:node-set($repositoryinfo)/county"/></StateProvince>
					</xsl:if>
					<xsl:if test="$country">
						<Country><xsl:value-of select="$country" /></Country>
					</xsl:if>
					<OriginalForm>
						<xsl:value-of select="." />
					</OriginalForm>
					<xsl:if test="ext:node-set($repositoryinfo)/website">
						<URL><xsl:value-of select="ext:node-set($repositoryinfo)/website" /></URL>
					</xsl:if>
					<xsl:if test="ext:node-set($repositoryinfo)/website/url">
						<URL><xsl:value-of select="ext:node-set($repositoryinfo)/website" /></URL>
					</xsl:if>
			</Contributor>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="BirthDate">
		<xsl:if test="pqfn:birthdate($birthdate)" >
			<BirthDate>
				<xsl:value-of select="pqfn:birthdate($birthdate)" />
			</BirthDate>
		</xsl:if>
	</xsl:template>

	<xsl:template name="DeathDate">
		<xsl:if test="pqfn:deathdate($deathdate)" >
			<DeathDate>
				<xsl:value-of select="pqfn:deathdate($deathdate)" />
			</DeathDate>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ContribDesc">
		<xsl:for-each select="$epithet" >
			<ContribDesc>
				<xsl:value-of select="$epithet" />
			</ContribDesc>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="TableOfContents">
		<xsl:if test="$toc">
			<TableOfContents>
				<xsl:copy-of select="$toc" />
			</TableOfContents>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Notes">
		<xsl:if test="$documentnote or $collurl or $typecoll or $pubnote or $physdescnote or $repositoryinfo">
			<Notes>
				<xsl:for-each select="$documentnote">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'Document'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="$collurl">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'Document'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="$typecoll">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'Document'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each>
				<!-- <xsl:for-each select="ext:node-set($publicationNote)">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'Publication'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each> -->
				<xsl:for-each select="$physdescnote">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'PhysDesc'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each>
				<!-- <xsl:for-each select="ext:node-set($mfextent)">
					<xsl:call-template name="Note">
					<xsl:with-param name="type" select="'Document'" />
					<xsl:with-param name="content" select="." />
					</xsl:call-template>
				</xsl:for-each> -->
				<xsl:if test="ext:node-set($repositoryinfo)/materials">
					<xsl:for-each select="ext:node-set($repositoryinfo)/materials">
						<xsl:call-template name="Note">
						<xsl:with-param name="type" select="'Publication'" />
						<xsl:with-param name="content" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="ext:node-set($repositoryinfo)/volume">
					<xsl:for-each select="ext:node-set($repositoryinfo)/volume">
						<xsl:call-template name="Note">
						<xsl:with-param name="type" select="'Publication'" />
						<xsl:with-param name="content" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="ext:node-set($repositoryinfo)/repdates">
					<xsl:for-each select="ext:node-set($repositoryinfo)/repdates">
						<xsl:call-template name="Note">
						<xsl:with-param name="type" select="'Publication'" />
						<xsl:with-param name="content" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="ext:node-set($repositoryinfo)/holdings">
					<xsl:for-each select="ext:node-set($repositoryinfo)/holdings">
						<xsl:call-template name="Note">
						<xsl:with-param name="type" select="'Publication'" />
						<xsl:with-param name="content" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="ext:node-set($repositoryinfo)/notes">
					<xsl:for-each select="ext:node-set($repositoryinfo)/notes">
						<xsl:call-template name="Note">
						<xsl:with-param name="type" select="'Publication'" />
						<xsl:with-param name="content" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</Notes>
		</xsl:if>
	</xsl:template>


	<xsl:template name="Note">
		<xsl:param name="type" />
		<xsl:param name="content" />
		<Note HTMLContent="true">
			<xsl:attribute name="NoteType"><xsl:value-of select="$type"/></xsl:attribute>
			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:apply-templates select="$content" />
			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</Note>
	</xsl:template>


	<xsl:template name="Terms">
		<xsl:if test="$nucmcsubj or $nidsubj or $location or $ncssubj" >
			<Terms>
				<!-- <xsl:call-template name="CompanyTerm" />
				<xsl:call-template name="PersonalTerm" />
				<xsl:call-template name="GeographicTerm" /> -->
				<!-- <xsl:call-template name="GenSubj" /> -->
				<xsl:for-each select='$nucmcsubj'>
					<GenSubjTerm TermVocab='NUCMC'>
						<GenSubjValue>
							<xsl:value-of select='.' />
						</GenSubjValue>
					</GenSubjTerm>
				</xsl:for-each>
				<xsl:for-each select='$nidsubj'>
					<GenSubjTerm TermVocab='NIDS'>
						<GenSubjValue>
							<xsl:value-of select='.' />
						</GenSubjValue>
					</GenSubjTerm>
				</xsl:for-each>
				<!-- <xsl:call-template name="FlexTerm" />
				<xsl:call-template name="Term" /> -->
			</Terms>
		</xsl:if>
	</xsl:template>

	<xsl:template name="GenSubj">
		<xsl:for-each select="$generalsubj">
			<GenSubjTerm>
				<GenSubjValue>
					<xsl:value-of select="." />
				</GenSubjValue>
			</GenSubjTerm>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="FlexTerm">
		<xsl:for-each select="$location">
			<FlexTerm>
			<xsl:attribute name="FlexTermName"><xsl:value-of select="@FlexTermName|../@FlexTermName" /></xsl:attribute>
				<FlexTermValue>
					<xsl:value-of select="." />
				</FlexTermValue>
			</FlexTerm>
		</xsl:for-each>
		<xsl:for-each select="$ncssubj">
			<FlexTerm>
			<xsl:attribute name="FlexTermName"><xsl:value-of select="@FlexTermName" />NSTCMFCollection</xsl:attribute>
				<FlexTermValue>
					<xsl:value-of select="." />
				</FlexTermValue>
			</FlexTerm>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="CompanyTerm">
		<xsl:for-each select="$companySubject">
				<CompanyTerm>
					<CompanyName><xsl:value-of select="." /></CompanyName>
				</CompanyTerm>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="PersonalTerm">
		<xsl:for-each select="$personalSubject">
			<Term TermType="Personal">
				<TermValue><xsl:value-of select="." /></TermValue>
			</Term>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="GeographicTerm">
		<xsl:for-each select="$geographicSubject">
			<Term TermType="Geographic">
				<TermValue><xsl:value-of select="." /></TermValue>
			</Term>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="KeyedFullText">
		<xsl:if test="$keyedfulltext">
			<TextInfo>
				<Text HTMLContent="true">
					<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
						<xsl:copy-of select="$keyedfulltext" />
					<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
				</Text>
			</TextInfo>
		</xsl:if>
	</xsl:template>

	<xsl:template name="ComponentFullText">
		<xsl:if test="$keyedfulltext">
			<Component ComponentType="FullText">
				<Representation RepresentationType="FullText">
					<MimeType>text/xml</MimeType>
					<Resides>FAST</Resides>
				</Representation>
			</Component>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PublicationInfo">
		<xsl:if test="$pubtitle or $volume or $issue or $publisherorg or $publishercity or $publicationseries or $publicationimprint">
			<PublicationInfo>
				<xsl:call-template name="PublicationTitle" />
				<xsl:call-template name="Volume" />
				<xsl:call-template name="Issue" />
				<xsl:call-template name="Series" />
				<xsl:call-template name="Publisher" />
				<xsl:call-template name="Imprint" />
			</PublicationInfo>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PublicationTitle">
		<xsl:if test="$pubtitle">
			<PublicationTitle>
				<xsl:value-of select="$pubtitle" />
			</PublicationTitle>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Volume">
		<xsl:if test="$volume">
			<Volume>
				<xsl:value-of select="$volume" />
			</Volume>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Issue">
		<xsl:if test="$issue">
			<Issue>
				<xsl:value-of select="$issue" />
			</Issue>
		</xsl:if>
	</xsl:template>


	<xsl:template name="Publisher">
		<xsl:if test="$publisherorg or $publishercity">
			<Publisher>
				<xsl:call-template name="OrganizationName" />
				<xsl:call-template name="CityName" />
			</Publisher>
		</xsl:if>
	</xsl:template>

	<xsl:template name="OrganizationName">
		<xsl:if test="$publisherorg">
			<OrganizationName>
				<xsl:value-of select="$publisherorg" />
			</OrganizationName>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CityName">
		<xsl:if test="$publishercity">
			<CityName>
				<xsl:value-of select="$publishercity" />
			</CityName>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Series">
		<xsl:if test="$publicationseries">
			<Series>
				<xsl:value-of select="$publicationseries" />
			</Series>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Imprint">
		<xsl:if test="$publicationimprint">
			<Imprint>
				<xsl:value-of select="$publicationimprint" />
			</Imprint>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PDF">
		<xsl:if test="$pdf">
			<Component ComponentType="FullText">
				<Representation RepresentationType="PDFFullText">
					<MimeType>application/pdf</MimeType>
					<Resides>HMS</Resides>
					<Bytes><xsl:value-of select="$pdfbytes" /></Bytes>
					<PDFType>300PDF</PDFType>
					<MediaKey>/media<xsl:value-of select="$pdf" /></MediaKey>
				</Representation>
			</Component>
		</xsl:if>
	</xsl:template>

	<xsl:template name="DPMI">
		<xsl:if test="$dpmi">
			<Component ComponentType="Pages">
				<PageCount><xsl:value-of select="$dpmicount" /></PageCount>
				<Representation RepresentationType="DPMI">
					<MimeType>text/xml</MimeType>
					<Resides>HMS</Resides>
					<MediaKey>/media<xsl:value-of select="$dpmi" /></MediaKey>
				</Representation>
			</Component>
		</xsl:if>
	</xsl:template>

	<xsl:template name="DocFeatures">
		<xsl:if test="$docfeatures">
			<DocFeatures>
				<xsl:call-template name="DocFeature" />
			</DocFeatures>
		</xsl:if>
	</xsl:template>

	<xsl:template name="DocFeature">
		<xsl:for-each select="$docfeatures">
			<DocFeature>
				<xsl:value-of select="." />
			</DocFeature>
		</xsl:for-each>
	</xsl:template>

	<!-- A template which accepts an input field but has defaults -->
	<xsl:template name="match_or_default">
		<xsl:param name="match_field" />
		<xsl:param name="default_value" />
		<xsl:choose>
			<xsl:when test="$match_field">
				<xsl:value-of select="$match_field" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default_value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
		<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
  	</xsl:template>

	<!-- The main IngestRecord template, matching the whole input record -->
	<xsl:template match="/">
		<IngestRecord>
			<MinorVersion>
				<xsl:call-template name="match_or_default">
					<xsl:with-param name="match_field" select="MinorVersion" />
					<xsl:with-param name="default_value" select="'64'" />
				</xsl:call-template>
			</MinorVersion>
			<ControlStructure>
				<ActionCode>add</ActionCode>
				<LegacyPlatform>CH</LegacyPlatform>
				<LegacyID>
					<xsl:value-of select="$prefixid" />
				</LegacyID>
                    <LastLegacyUpdateTime>
                        <xsl:call-template name="l:timeStamp">
                            <xsl:with-param name="dateString" select="date:date-time()" />
                        </xsl:call-template>
                    </LastLegacyUpdateTime>
				<PublicationInfo>
					<LegacyPubID>
                        <xsl:if test="$pubid = 'ArchivesUSA'">C19-ausa</xsl:if>
                        <xsl:if test="$pubid = 'C19-nids'">C19-nids</xsl:if>
					</LegacyPubID>
				</PublicationInfo>
				<Component ComponentType="Citation">
					<Representation RepresentationType="Citation">
						<MimeType>text/xml</MimeType>
						<Resides>FAST</Resides>
					</Representation>
				</Component>
                <xsl:call-template name="ComponentAbstract" />
				<!--<xsl:call-template name="ComponentFullText" />
				<xsl:call-template name="PDF" />
				<xsl:call-template name="DPMI" /> -->
			</ControlStructure>

			<RECORD>
				<Version>Global_Schema_v5.1.xsd</Version>
				<ObjectInfo>
					<xsl:call-template name="SourceType" />
					<xsl:call-template name="ObjectType" />
					<xsl:call-template name="Title" />
					<xsl:call-template name="AlternateTitle" />
					<xsl:call-template name="ObjectNumericDate" />
					<xsl:call-template name="ObjectStartDate" />
					<xsl:call-template name="ObjectEndDate" />
					<xsl:call-template name="DisplayDate" />
					<!-- <xsl:call-template name="Language" />
					<xsl:call-template name="CopyrightData" />
					<xsl:call-template name="PrintLocation" /> -->
					<xsl:call-template name="ObjectIDs" />
					<!-- <xsl:call-template name="DocFeatures" /> -->
					<xsl:call-template name="Contributors" />
					<!-- <xsl:call-template name="TableOfContents" /> -->
					<xsl:call-template name="Notes" />
					<xsl:call-template name="DisplayAbstract" />
					<xsl:call-template name="Terms" />
					<!-- <xsl:call-template name="KeyedFullText" /> -->
				</ObjectInfo>
				<!-- <xsl:call-template name="PublicationInfo" /> -->
			</RECORD>
		</IngestRecord>
	</xsl:template>


<!-- NOTES - delete when no longer needed -->


<!-- <xsl:template match="Contributor|Contributor/item">
		<Contributor>
			<xsl:attribute name="ContribRole"><xsl:value-of select="@ContribRole" /></xsl:attribute>
			<xsl:attribute name="ContribOrder"><xsl:value-of select="position()" /></xsl:attribute>
			<xsl:apply-templates select="./OriginalForm|./ContribAffiliationSummary" />
		</Contributor>
	</xsl:template>

	<xsl:template match="//root/Contributor/OriginalForm|//root/Contributor/item">
		<OriginalForm><xsl:value-of select="." /></OriginalForm>
	</xsl:template>

	<xsl:template match="//root/Contributor/ContribAffiliationSummary">
		<ContribAffiliationSummary><xsl:value-of select="." /></ContribAffiliationSummary>
	</xsl:template>


	<xsl:template match="//root/GenSubjTerm/text()|//root/GenSubjTerm/item">
		<GenSubjTerm>
			<GenSubjValue>
				<xsl:value-of select="." />
			</GenSubjValue>
		</GenSubjTerm>
	</xsl:template>

	<xsl:template match="//root/Term/item|//root/Term/text()">
		<Term>
			<xsl:attribute name="TermType">
				<xsl:value-of select="../@Type" />
			</xsl:attribute>
			<TermValue>
				<xsl:value-of select="." />
			</TermValue>
		</Term>
	</xsl:template>

	<xsl:template match="//root/HistoryTerm/item">
		<HistoryTerm>
			<xsl:attribute name="HistoryTermName">
				<xsl:value-of select="../@TermName" />
			</xsl:attribute>
			<HistoryTermValue>
				<xsl:value-of select="." />
			</HistoryTermValue>
		</HistoryTerm>
	</xsl:template>

	<xsl:template match="//root/FlexTerm/text()|//root/FlexTerm/item">
		<FlexTerm>
			<xsl:attribute name="FlexTermName"><xsl:value-of select="@FlexTermName|../@FlexTermName" /></xsl:attribute>
			<FlexTermValue><xsl:value-of select="." /></FlexTermValue>
		</FlexTerm>
	</xsl:template>

	<xsl:template match="//root/GenericData">
		<GenericData>
			<xsl:attribute name="GenericDataName"><xsl:value-of select="@Type" /></xsl:attribute>
			<xsl:value-of select="." />
		</GenericData>
	</xsl:template> -->


</xsl:stylesheet>
