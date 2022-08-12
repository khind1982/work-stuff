import sys
import os
import argparse
import logging

import lxml.etree as et

from pqcoreutils import fileutils


def parse_args(args):
    """Parse command line input"""
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', dest='collection_data', help='Path to the collections data', required=True)
    parser.add_argument('-r', dest='repository_data', help='Path to the repository level data', required=True)
    parser.add_argument('-o', dest='outdir', help='Output directory for the ingest files', required=True)
    parser.add_argument('--targets', dest='targets', help="File containing target record IDs")
    parser.add_argument('-ll', dest='loglvl',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
        default='ERROR',
        help="Set the level for the logger")
    return parser.parse_args(args)


def setup_logger(loglvl):
    logger = logging.getLogger('citations')
    logging.basicConfig(level=loglvl)
    return logger


def record_iterator(fpath):
    """Loop through each record"""
    for _,record in et.iterparse(fpath, tag='rec', html=True):
        yield record


def render_ingest_record(record, transform):
    output = transform(record)
    return output


def create_repository_record_index(repository_records):
    '''Given a generator object containing repository records
        when executed add the record as a value to the dictionary
        with the //rid as key'''
    repository_index = {}
    for record in repository_records:
        repository_index[record.xpath('.//rid')[0].text] = record
    return repository_index


def append_repository_info_to_record(record, repository_index):
    '''Given a collection record when executed match the //rid
        with the index in the repository index and append the
        repository record to the collection record.'''
    matching_repository_record = repository_index[record.xpath('.//rid')[0].text]
    rec_elem = record.xpath('.//rec')[0]
    repository_element = et.SubElement(rec_elem, 'repository')
    for elem in matching_repository_record.iter():
        if elem.tag != 'rec':
            repository_element.append(elem)
    # print(et.tostring(record, pretty_print=True).decode())
    return record


def main(args):
    print(args)
    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)
    num = 0
    logger = setup_logger(args.loglvl)
    xslt = et.parse(os.path.join(os.path.dirname(__file__), "xsl/archive_finder_ingest_record.xsl"))
    transform = et.XSLT(xslt)
    collection_records = record_iterator(args.collection_data)
    repository_records = record_iterator(args.repository_data)
    targets = None
    if args.targets:
        if os.path.isfile(args.targets):
            targets = fileutils.read_lookup_file(args.targets)
        else:
            targets = args.targets
    for rec in collection_records:
        num += 1
        try:
            recid = rec.xpath('.//recid')[0].text
        except IndexError:
            continue
        logger.debug(f"Seen {num} records in collection data file.  Current record {recid}.")
        if targets and recid not in targets:
            continue
        ingest_record = render_ingest_record(rec, transform)
        docid = ingest_record.xpath('.//ControlStructure/LegacyID')[0].text
        # TODO: Ensure output files have the standard syntax for being able to upload via chsubmit
        with open(f'{args.outdir}/{docid}.xml', 'w') as outf:
            outf.write(et.tostring(ingest_record, pretty_print=True, xml_declaration=True, encoding='utf-8').decode())


if __name__ == "__main__":
    main(parse_args(sys.argv[1:]))
