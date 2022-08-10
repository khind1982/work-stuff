import os
import sys
import pytest

import lxml.etree as et

from collections import namedtuple

import ingest.archive.citations as citations

parser = et.HTMLParser(remove_blank_text=True)

@pytest.fixture
def output_dir(tmpdir_factory):
    outdir = tmpdir_factory.mktemp("ingestout")
    return outdir


@pytest.fixture
def xslt_transform():
    xslt = et.parse(os.path.join(os.path.dirname(__file__), "../ingest/archive/xsl/archive_finder_ingest_record.xsl"))
    transform = et.XSLT(xslt)
    return transform


@pytest.fixture
def collections_input_data():
    return os.path.join(os.path.dirname(__file__), "./test_data/archivefinder/collections.xml")


@pytest.fixture
def repository_input_data():
    return os.path.join(os.path.dirname(__file__), "./test_data/archivefinder/repository.xml")


@pytest.fixture
def collections_input_record():
    return et.fromstring(
    """
    <rec>
        <product>ArchivesUSA</product>
        <recid>54</recid>
        <lcn>00510551</lcn>
        <idref>00510551</idref>
        <fiche>3.276.224</fiche>
        <nucmcno>MS 89-625</nucmcno>
        <collname>James family</collname>
        <desc>Assembled collection of materials related to Alvah James, his wife Allie, and daughter Helen James. The materials consist primarily of correspondence from the Grey family and copies of magazine articles written by Alvah James. Correspondents incluce Lina Elise Roth Grey and Zane Grey. Arranged in 4 subseries: Alvah James, Allie James, Alvah and Allie James, and Helen James Johnson Davis.</desc>
        <notes>Zane Grey Museum; (UPDE 902).</notes>
        <date1>1903-1985</date1>
        <extent>.25 linear ft.</extent>
        <rid>PA75-100</rid>
        <rname>Zane Grey Museum</rname>
        <city>Beach Lake</city>
        <state>PA</state>
        <statefull>Pennsylvania</statefull>
        <country>USA</country>
        <type>Papers.</type>
        <datesrt>1903-1985</datesrt>
        <dates>1903-1985</dates>
        <year1>1903</year1>
        <year2>1985</year2>
        <nucmcterm>Davis, Helen James Johnson, d. 1996; Correspondence.</nucmcterm>
        <nucmcterm>Gray family; Correspondence.</nucmcterm>
        <nucmcterm>Grey family; Correspondence.</nucmcterm>
        <nucmcterm>Grey, Lina Elise, d. 1957; Correspondence.</nucmcterm>
        <nucmcterm>Grey, Zane, 1872-1939; Correspondence.</nucmcterm>
        <nucmcterm>James family; Correspondence.</nucmcterm>
        <nucmcterm>James, Allie, d. 1958; Correspondence.</nucmcterm>
        <nucmcterm>James, Alvah, d. 1958.</nucmcterm>
        <nucmcterm>Lackawaxen (Pa.).</nucmcterm>
        <nucmcterm>Photographs; United States.</nucmcterm>
        <nidsterm>Planned Parenthood of Maryland</nidsterm>
        <nidsterm>Berkowitz, Bernard L.</nidsterm>
        <findaid>Finding aid available in the repository and on the Internet. <url>http://www.leesburgva.gov/index.aspx?page=996</url></findaid>
    </rec>
    """, parser
    )



def test_record_iterator_collections(collections_input_data):
    docids = [record.xpath('.//recid')[0].text for record in citations.record_iterator(collections_input_data)]
    assert '54' in docids
    assert '150775' in docids


def test_record_iterator_repository(repository_input_data):
    docids = [record.xpath('.//recid')[0].text for record in citations.record_iterator(repository_input_data)]
    assert '5045' in docids
    assert '1796' in docids


def test_render_ingest_record_basic_structure(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath('.//MinorVersion')[0].text == '64'
    assert actual.xpath('.//ControlStructure/ActionCode')[0].text == 'add'
    assert actual.xpath('.//ControlStructure/LegacyPlatform')[0].text == 'CH'
    assert actual.xpath('.//ControlStructure/LegacyID')[0].text == 'archives-54'
    assert actual.xpath('.//ControlStructure/PublicationInfo/LegacyPubID')[0].text == 'C19-ausa'
    assert actual.xpath(".//ControlStructure/Component[@ComponentType='Citation']")
    assert actual.xpath(".//ControlStructure/Component[@ComponentType='Citation']/Representation[@RepresentationType='Citation']")
    assert actual.xpath(".//MimeType")[0].text == 'text/xml'
    assert actual.xpath(".//Resides")[0].text == 'FAST'
    assert actual.xpath(".//RECORD/Version")[0].text == 'Global_Schema_v5.1.xsd'


def test_render_ingest_record_source_types_object_types(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath('.//ObjectInfo/SourceType')[0].text == 'Archival Materials'
    assert actual.xpath('.//ObjectInfo/ObjectType')[0].text == 'Archival Collection'


def test_render_ingest_record_titles(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath('.//ObjectInfo/Title')[0].text == 'James family'


def test_render_ingest_record_abstract_fields(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath(".//ObjectInfo/Abstract[@AbstractType='Summary']")
    assert 'Assembled collection of materials related to Alvah James' in et.tostring(actual.xpath(
        ".//ObjectInfo/Abstract[@AbstractType='Summary']/AbsText")[0]).decode()
    assert actual.xpath(".//ControlStructure/Component[@ComponentType='Abstract']")
    assert actual.xpath(".//ControlStructure/Component[@ComponentType='Abstract']/Representation[@RepresentationType='Abstract']")
    assert actual.xpath(".//Component[@ComponentType='Abstract']/Representation[@RepresentationType='Abstract']/MimeType")[0].text == 'text/xml'
    assert actual.xpath(".//Component[@ComponentType='Abstract']/Representation[@RepresentationType='Abstract']/Resides")[0].text == 'FAST'


def test_render_ingest_record_dates(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath(".//ObjectInfo/ObjectNumericDate")[0].text == '19030101'
    assert actual.xpath(".//ObjectInfo/ObjectRawAlphaDate")[0].text == '1903-1985'
    assert actual.xpath(".//ObjectInfo/ObjectStartDate")[0].text == '19030101'
    assert actual.xpath(".//ObjectInfo/ObjectEndDate")[0].text == '19850101'


def test_render_ingest_record_notes(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert 'Zane Grey Museum; (UPDE 902).' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Document"]')[0]).decode()
    assert '.25 linear ft.' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="PhysDesc"]')[0]).decode()
    assert 'http://www.leesburgva.gov/index.aspx?page=996' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Document"]')[1]).decode()
    assert 'Papers.' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Document"]')[2]).decode()


def test_render_ingest_record_objectids(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath('.//ObjectInfo/ObjectIDs/ObjectID[@IDType="CHLegacyID"]')[0].text == 'archives-54'
    assert actual.xpath('.//ObjectInfo/ObjectIDs/ObjectID[@IDType="CHOriginalLegacyID"]')[0].text == '54'
    assert actual.xpath('.//ObjectInfo/ObjectIDs/ObjectID[@IDType="AccNum"]')[0].text == '00510551'
    assert actual.xpath('.//ObjectInfo/ObjectIDs/ObjectID[@IDType="FicheNum"]')[0].text == '3.276.224'
    assert actual.xpath('.//ObjectInfo/ObjectIDs/ObjectID[@IDType="NUCMC"]')[0].text == 'MS 89-625'


def test_render_ingest_record_terms(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual))
    assert actual.xpath('.//ObjectInfo/Terms/GenSubjTerm[@TermVocab="NUCMC"]/GenSubjValue')[0].text == 'Davis, Helen James Johnson, d. 1996; Correspondence.'
    assert actual.xpath('.//ObjectInfo/Terms/GenSubjTerm[@TermVocab="NIDS"]/GenSubjValue')[0].text == 'Planned Parenthood of Maryland'
    # assert actual.xpath('.//ObjectInfo/Terms/FlexTerm[@FlexTermName="RecordGroup"]/FlexTermValue')[0].text == ''


def test_render_ingest_record_contributor(collections_input_record, xslt_transform):
    actual = citations.render_ingest_record(collections_input_record, xslt_transform)
    print(et.tostring(actual, pretty_print=True).decode())
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]')
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]/OriginalForm')[0].text == 'Zane Grey Museum'


def test_create_repository_record_index(repository_input_data):
    repository_records = citations.record_iterator(repository_input_data)
    repository_index = citations.create_repository_record_index(repository_records)
    assert 'PA75-100' in repository_index.keys()
    assert 'ME712-530' in repository_index.keys()


def test_append_repository_info_to_record(collections_input_record, repository_input_data):
    repository_records = citations.record_iterator(repository_input_data)
    repository_index = citations.create_repository_record_index(repository_records)
    actual = citations.append_repository_info_to_record(collections_input_record, repository_index)
    assert actual.xpath('.//repository')
    assert actual.xpath('.//repository/recid')[0].text == '5045'
    assert actual.xpath('.//repository/zip')[0].text == '18405-4046'


def test_render_ingest_record_with_repository_elements(collections_input_record, repository_input_data, xslt_transform):
    repository_records = citations.record_iterator(repository_input_data)
    repository_index = citations.create_repository_record_index(repository_records)
    citation_input = citations.append_repository_info_to_record(collections_input_record, repository_index)
    actual = citations.render_ingest_record(citation_input, xslt_transform)
    print(et.tostring(actual, pretty_print=True).decode())
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]/City')[0].text == 'Beach Lake'
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]/StateProvince')[0].text == 'Pennsylvania'
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]/Country')[0].text == 'USA'
    assert actual.xpath('.//ObjectInfo/Contributors/Contributor[@ContribRole ="SourceInstitution"]/URL')[0].text == 'http://www.nps.gov/upde/historyculture/zanegrey.htm'


def test_render_ingest_record_with_repository_elements_notes(collections_input_record, repository_input_data, xslt_transform):
    repository_records = citations.record_iterator(repository_input_data)
    repository_index = citations.create_repository_record_index(repository_records)
    citation_input = citations.append_repository_info_to_record(collections_input_record, repository_index)
    actual = citations.render_ingest_record(citation_input, xslt_transform)
    print(et.tostring(actual, pretty_print=True).decode())
    assert actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')
    assert 'Materials relating to Alvah James and Zane Grey.' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')[0]).decode()
    assert '733 square feet' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')[1]).decode()
    assert '1492 - present' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')[2]).decode()
    assert 'Correspondence, newspaper articles, photographs, furniture and more.' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')[3]).decode()
    assert 'Applications in writing required to make use of the collection.' in et.tostring(actual.xpath('.//ObjectInfo/Notes/Note[@NoteType="Publication"]')[4]).decode()


def test_main(output_dir, collections_input_data, repository_input_data):
    '''
    Given arguments ensure that output directory is created
    if it doesn't exist and that all files in a directory are processed.
    '''
    args = namedtuple('args', 'collection_data repository_data outdir targets')
    sample_args = args(
        collection_data=collections_input_data,
        repository_data=repository_input_data,
        outdir=output_dir,
        targets=None)
    citations.main(sample_args)
    assert len(os.listdir(output_dir)) == 2
