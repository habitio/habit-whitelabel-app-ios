@Grab('com.xlson.groovycsv:groovycsv:1.1') //on 1st run it will download this

import static com.xlson.groovycsv.CsvParser.parseCsv

def url = 'https://docs.google.com/spreadsheets/d/1D1Uy14dIQCH1uTjFCV4fluZ9np_1CZ0KJdgJY1tyKNE/export?format=csv&id=1D1Uy14dIQCH1uTjFCV4fluZ9np_1CZ0KJdgJY1tyKNE&gid=1434198144'.toURL()


def input = url.getText('utf8').readLines()
//fix headers
def header = 'KEY'+input[0]
input = [header] + input[2..-1]

def ttt = input.join('\n').replace('\\n','NEWLINE') //hack, because \n gets mangled by the csv lib

def languages = [
	[lang:'ENGLISH', path:'Base', output:[]], 
	[lang:'FRENCH', path:'fr', output:[]],
	[lang:'PORTUGUESE', path:'pt-PT', output:[]], 
	[lang:'ROMANIAN', path:'ro-RO', output:[]], 
	]

parseCsv(ttt).each { line ->
	def key = line.KEY.toLowerCase()
	if (key.startsWith('mobile_') && !key.startsWith('mobile_android')) {
		languages.each {  
			def value = line[it.lang]
				.replace('NEWLINE','\\n')
				.replace("\'","\\'")
				.replace("%s","%@").replace("\$s","\$@")
			it.output << /"$key" = "$value";/
		}
	}
}

languages.each { 
	new File(it.path+ '.lproj/Localizable.strings' ).write(it.output.sort().join('\n'))
}
