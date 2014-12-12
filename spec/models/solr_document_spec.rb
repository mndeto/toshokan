# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'openurl'

describe "SolrDocument" do

  it "registers its export formats" do
    document = SolrDocument.new
    expect(Set.new(document.export_formats.keys)).to be_superset(Set.new([:bib, :ris]))
  end

  let(:article) do
    SolrDocument.new({
      :format  => "article",
      :title_ts => "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)",
      :author_ts => ["Kawauchi, Gisele Y.", "Giribet, Gonzalo"],
      :pub_date_tis => "2010",
      :language_ss => "English",
      :issn_ss => ["00253162", "14321793"],
      :journal_title_ts => "Marine Biology",
      :publisher_ts => "Springer-Verlag",
      :doi_ss => "10.1007/s00227-010-1402-z",
      :journal_page_ssf => "1417-1431"
    })
  end

  let(:book) do
    SolrDocument.new({
      "publisher_ts" => ["Polyteknisk Forlag"],
      "member_id_ss" => ["316397882"],
      "title_ts" => ["Kemiske enhedsoperationer"],
      "source_ss" => ["alis"],
      "format" => "book",
      "pub_date_tis" => [2004],
      "journal_page_ssf" => ["597 sider"],
      "keywords_ts" => ["kemiske enhedsoperationer.", "lærebøger."],
      "keywords_facet" => ["kemiske enhedsoperationer.", "lærebøger."],
      "isbn_ss" => ["8750209418", "9788750209416"],
      "cluster_id_ss" => ["191135307"],
      "source_id_ss" => ["alis:000461671"],
      "author_ts" => ["Clement, Karsten H.,, et al."],
      "author_facet" => ["Clement, Karsten H.,, et al."],
      "source_type_ss" => ["other"]
    })
  end

  describe "#to_bibtex" do
    it "generates a BibTeX reference for an article" do
      ref = article.to_bibtex
      expect(ref.title).to match "cosmopolitan sipunculan worms"
      expect(ref.author).to match "Kawauchi"
      expect(ref.author).to match "Giribet"
      expect(ref.issn).to match "00253162"
      expect(ref.year).to eq 2010
    end

    it "generates a BibTeX reference for a book" do
      ref = book.to_bibtex
      expect(ref.title).to eq "Kemiske enhedsoperationer"
    end
  end

  describe "#export_as_ris" do
    it "generates a RIS reference for an article" do
      ref = article.export_as_ris
      expect(ref).to match "TI  - Are there true cosmopolitan sipunculan worms?"
      expect(ref).to match "SP  - 1417"
      expect( ref).to match "EP  - 1431"
    end
  end

  describe "#export_as_citation_txt" do
    it "generates a citation" do
      article.citation_styles.each do |style|
        citation = article.export_as_citation_txt(style)
        expect(citation).to match /Cosmopolitan Sipunculan Worms/i
      end
    end
  end

  describe "#export_as_openurl_ctx_kev" do
    it "generates an OpenUrl for an article" do
      openurl = OpenURL::ContextObject.new_from_kev(article.export_as_openurl_ctx_kev)
      expect(openurl.referent.format).to eq "journal"
      expect(openurl.referent.metadata["genre"]).to eq "article"
      expect(openurl.referent.metadata["au"]).to eq "Kawauchi, Gisele Y."
      expect(openurl.referent.metadata["date"]).to eq "2010"
      expect(openurl.referent.metadata["atitle"]).to match /Are there true cosmopolitan sipunculan worms/
      expect(openurl.referent.metadata["jtitle"]).to eq "Marine Biology"
      expect(openurl.referent.identifiers).to include "urn:issn:00253162"
      expect(openurl.referent.identifiers).to include "urn:issn:14321793"
      expect(openurl.referent.identifiers).to include "info:doi/10.1007/s00227-010-1402-z"
      expect(openurl.referent.metadata["doi"]).to eq "10.1007/s00227-010-1402-z"
      expect(openurl.referent.metadata["spage"]).to eq "1417"
      expect(openurl.referent.metadata["epage"]).to eq "1431"
      expect(openurl.referent.metadata["pub"]).to eq "Springer-Verlag"
    end

    it "generates an OpenUrl for a book" do
      openurl = OpenURL::ContextObject.new_from_kev(book.export_as_openurl_ctx_kev)
      expect(openurl.referent.format).to eq "book"
      expect(openurl.referent.metadata["genre"]).to eq "book"
      expect(openurl.referent.metadata["pub"]).to eq "Polyteknisk Forlag"
      expect(openurl.referent.metadata["btitle"]).to eq "Kemiske enhedsoperationer"
      expect(openurl.referent.metadata["date"]).to eq "2004"
      expect(openurl.referent.metadata["isbn"]).to eq "9788750209416"
      expect(openurl.referent.identifiers).to include "urn:isbn:8750209418"
      expect(openurl.referent.identifiers).to include "urn:isbn:9788750209416"
      expect(openurl.referent.metadata["au"]).to eq "Clement, Karsten H.,, et al."
      expect(openurl.referent.private_data).to eq '{"id":"191135307","alis_id":"000461671"}'
    end

    it "sets the start or end pages even when pages element is not well formed" do
      openurl = OpenURL::ContextObject.new_from_kev(
        SolrDocument.new({
          'title_ts'=>['STREAMLINE CURVATURE COMPUTING PROCEDURES FOR FLUID-FLOW PROBLEMS'],
          'journal_issue_ssf'=>['4'],
          'issn_ss'=>['00220825', '2161945x'],
          'source_id_ss'=>['isi:A1967A075300004'],
          'journal_vol_ssf'=>['89'],
          'journal_title_ts'=>['JOURNAL OF ENGINEERING FOR POWER'],
          'format'=>'article',
          'language_ss'=>['English'],
          'pub_date_tis'=>[1967],
          'journal_page_ssf'=>['478-&'],
          'cluster_id_ss'=>['152427633'],
          'author_ts'=>['Novak, RA']
        }).export_as_openurl_ctx_kev)
      expect(openurl.referent.metadata["spage"]).to eq "478"
      expect(openurl.referent.metadata["epage"]).to be_nil

      openurl = OpenURL::ContextObject.new_from_kev(
        SolrDocument.new({
          'title_ts'=>['PEDESTRIAN FLOW CHARACTERISTICS'],
          'journal_issue_ssf'=>['9'],
          'issn_ss'=>['00410675'],
          'journal_vol_ssf'=>['39'],
          'journal_title_ts'=>['Traffic Eng'],
          'format'=>'article',
          'pub_date_tis'=>[1969],
          'journal_page_ssf'=>['30-3, 36'],
          'author_ts'=>['NAVIN FPD', 'WHEELER RJ']
        }).export_as_openurl_ctx_kev)
      expect(openurl.referent.metadata["spage"]).to eq "30"
      expect(openurl.referent.metadata["epage"]).to be_nil
    end
  end

  describe ".create_from_openURL" do

    let(:article) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver"     => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver"     => "Z39.88-2004",
          "ctx_enc"     => "info:ofi/enc:UTF-8",
          "rft.genre"   => "article",
          "rft.atitle"  => "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)",
          "rft.au"      => "Kawauchi, Gisele Y.",
          "rft.jtitle"  => "MARINE BIOLOGY",
          "rft.volume"  => "157",
          "rft.issue"   => "7",
          "rft.spage"   => "1417",
          "rft.epage"   => "1431",
          "rft.date"    => "2010",
          "rft.issn"    => "14321793",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:journal",
          "rft_id"      => ["urn:issn:00253162", "urn:issn:14321793", "info:doi/10.1007/s00227-010-1402-z"]
        }))
    end

    it "creates a valid Solr document for an article" do
      expect(article["format"]).to eq "article"
      expect(article["title_ts"].first).to eq "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)"
      expect(article["author_ts"].first).to eq "Kawauchi, Gisele Y."
      expect(article["journal_title_ts"].first).to eq "MARINE BIOLOGY"
      expect(article["journal_vol_ssf"].first).to eq "157"
      expect(article["journal_issue_ssf"].first).to eq "7"
      expect(article["journal_page_ssf"].first).to eq "1417-1431"
      expect(article["pub_date_tis"].first).to eq "2010"
      expect(article["doi_ss"].first).to eq "10.1007/s00227-010-1402-z"
      expect(article["issn_ss"]).to match_array ["00253162", "14321793"]
    end

    let(:book) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver" => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver" => "Z39.88-2004",
          "ctx_enc" => "info:ofi/enc:UTF-8",
          "rft.genre" => "book",
          "rft.btitle" => "Advanced engineering mathematics",
          "rft.au" => ["Zill, Dennis G.", "Wright, Warren S."],
          "rft.date" => "2014",
          "rft.isbn" => "9781449679774",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:book",
          "rft_id" => ["urn:isbn:9781449693022", "urn:isbn:9781449679774"]
        }))
    end

    it "creates a valid Solr document for a book" do
      expect(book["format"]).to eq "book"
      expect(book["title_ts"].first).to eq "Advanced engineering mathematics"
      expect(book["author_ts"].first).to eq "Zill, Dennis G."
      expect(book["pub_date_tis"].first).to eq "2014"
      expect(book["isbn_ss"]).to match_array ["9781449693022", "9781449679774"]
    end

    let(:journal) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver" => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver" => "Z39.88-2004",
          "ctx_enc" => "info:ofi/enc:UTF-8",
          "rft.genre" => "journal",
          "rft.jtitle" => "Accident analysis and prevention",
          "rft.issn" => "18792057",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:journal",
          "rft_id" => ["urn:issn:00014575", "urn:issn:18792057"]
        }))
    end

    it "creates a valid Solr document for a journal" do
      expect(journal["format"]).to eq "journal"
      expect(journal["title_ts"].first).to eq "Accident analysis and prevention"
      expect(journal["journal_title_ts"].first).to eq "Accident analysis and prevention"
      expect(journal["issn_ss"]).to match_array ["00014575", "18792057"]
    end
  end
end
