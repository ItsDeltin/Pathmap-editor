#Global variables

globalvar pfLoadedMap_nodes
globalvar pfLoadedMap_neighbors
globalvar pfDecompress
globalvar compressionTable
globalvar i1
globalvar i2
globalvar decompressionState
globalvar currentNeighbors
globalvar next


rule "【PF Decompress】Decompress map":
    @Condition pfDecompress == true
    
    compressionTable = "{0}{1}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format("{0}{1}{2}".format(" !#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz|~\u007f\u0080\u0081\u0082\u0083\u0084\u0085\u0086\u0087\u0088\u0089\u008a\u008b\u008c\u008d\u008e\u008f\u0090\u0091\u0092\u0093\u0094\u0095\u0096\u0097\u0098\u0099\u009a\u009b\u009c\u009d\u009e\u009f\u00a0¡¢£", "¤¥¦§¨©ª«¬\z®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģ", "ĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƀƁƂƃƄƅƆƇƈƉƊƋƌƍƎƏƐƑƒƓƔƕƖƗƘƙƚƛƜƝƞƟƠơƢƣ"), "ƤƥƦƧƨƩƪƫƬƭƮƯưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿǀǁǂǃǄǅǆǇǈǉǊǋǌǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯǰǱǲǳǴǵǶǷǸǹǺǻǼǽǾǿȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȜȝȞȟȠȡȢȣ", "ȤȥȦȧȨȩȪȫȬȭȮȯȰȱȲȳȴȵȶȷȸȹȺȻȼȽȾȿɀɁɂɃɄɅɆɇɈɉɊɋɌɍɎɏɐɑɒɓɔɕɖɗɘəɚɛɜɝɞɟɠɡɢɣɤɥɦɧɨɩɪɫɬɭɮɯɰɱɲɳɴɵɶɷɸɹɺɻɼɽɾɿʀʁʂʃʄʅʆʇʈʉʊʋʌʍʎʏʐʑʒʓʔʕʖʗʘʙʚʛʜʝʞʟʠʡʢʣ"), "ʤʥʦʧʨʩʪʫʬʭʮʯʰʱʲʳʴʵʶʷʸʹʺʻʼʽʾʿˀˁ˂˃˄˅ˆˇˈˉˊˋˌˍˎˏːˑ˒˓˔˕˖˗˘˙˚˛˜˝˞˟ˠˡˢˣˤ˥˦˧˨˩˪˫ˬ˭ˮ˯˰˱˲˳˴˵˶˷˸˹˺˻˼˽˾˿̡̢̛̖̗̘̙̜̝̞̟̠̣̀́̂̃̄̅̆̇̈̉̊̋̌̍̎̏̐̑̒̓̔̕̚", "̴̵̶̷̸̧̨̤̥̦̩̪̫̬̭̮̯̰̱̲̳̹̺̻̼͇͈͉͍͎̽̾̿̀́͂̓̈́͆͊͋͌ͅ͏͓͔͕͖͙͚͐͑͒͗͛ͣͤͥͦͧͨͩͪͫͬͭͮͯ͘͜͟͢͝͞͠͡ͰͱͲͳʹ͵Ͷͷ\u0378\u0379ͺͻͼͽ;Ϳ\u0380\u0381\u0382\u0383΄΅Ά·ΈΉΊ\u038bΌ\u038dΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡ\u03a2Σ"), "ΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώϏϐϑϒϓϔϕϖϗϘϙϚϛϜϝϞϟϠϡϢϣϤϥϦϧϨϩϪϫϬϭϮϯϰϱϲϳϴϵ϶ϷϸϹϺϻϼϽϾϿЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУ", "ФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяѐёђѓєѕіїјљњћќѝўџѠѡѢѣѤѥѦѧѨѩѪѫѬѭѮѯѰѱѲѳѴѵѶѷѸѹѺѻѼѽѾѿҀҁ҂҃҄҅҆҇҈҉ҊҋҌҍҎҏҐґҒғҔҕҖҗҘҙҚқҜҝҞҟҠҡҢң"), "ҤҥҦҧҨҩҪҫҬҭҮүҰұҲҳҴҵҶҷҸҹҺһҼҽҾҿӀӁӂӃӄӅӆӇӈӉӊӋӌӍӎӏӐӑӒӓӔӕӖӗӘәӚӛӜӝӞӟӠӡӢӣӤӥӦӧӨөӪӫӬӭӮӯӰӱӲӳӴӵӶӷӸӹӺӻӼӽӾӿԀԁԂԃԄԅԆԇԈԉԊԋԌԍԎԏԐԑԒԓԔԕԖԗԘԙԚԛԜԝԞԟԠԡԢԣ", "ԤԥԦԧԨԩԪԫԬԭԮԯ\u0530ԱԲԳԴԵԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔՕՖ\u0557\u0558ՙ՚՛՜՝՞՟ՠաբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆևֈ։֊\u058b\u058c֍֎֏\u0590֑֖֛֢֣֚֒֓֔֕֗֘֙֜֝֞֟֠֡"), "ְֱֲֳִֵֶַָֹֺֻּֽ֤֥֦֧֪֭֮֨֩֫֬֯־ֿ׀ׁׂ׃ׅׄ׆ׇ\u05c8\u05c9\u05ca\u05cb\u05cc\u05cd\u05ce\u05cfאבגדהוזחטיךכלםמןנסעףפץצקרשת\u05eb\u05ec\u05ed\u05eeׯװױײ׳״\u05f5\u05f6\u05f7\u05f8\u05f9\u05fa\u05fb\u05fc\u05fd\u05fe\u05ff\u0600\u0601\u0602\u0603\u0604\u0605؆؇؈؉؊؋،؍؎؏ؘؙؚؐؑؒؓؔؕؖؗ؛\u061c؝؞؟ؠءآأ", "ؤإئابةتثجحخدذرزسشصضطظعغػؼؽؾؿـفقكلمنهوىيًٌٍَُِّْٕٖٜٟٓٔٗ٘ٙٚٛٝٞ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٮٯٰٱٲٳٴٵٶٷٸٹٺٻټٽپٿڀځڂڃڄڅچڇڈډڊڋڌڍڎڏڐڑڒړڔڕږڗژڙښڛڜڝڞڟڠڡڢڣ"), "ڤڥڦڧڨکڪګڬڭڮگڰڱڲڳڴڵڶڷڸڹںڻڼڽھڿۀہۂۃۄۅۆۇۈۉۊۋیۍێۏېۑےۓ۔ەۖۗۘۙۚۛۜ\u06dd۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬ۮۯ۰۱۲۳۴۵۶۷۸۹ۺۻۼ۽۾ۿ܀܁܂܃܄܅܆܇܈܉܊܋܌܍\u070e\u070fܐܑܒܓܔܕܖܗܘܙܚܛܜܝܞܟܠܡܢܣ", "ܤܥܦܧܨܩܪܫܬܭܮܯܱܴܷܸܹܻܼܾ݂݄݆݈ܰܲܳܵܶܺܽܿ݀݁݃݅݇݉݊\u074b\u074cݍݎݏݐݑݒݓݔݕݖݗݘݙݚݛݜݝݞݟݠݡݢݣݤݥݦݧݨݩݪݫݬݭݮݯݰݱݲݳݴݵݶݷݸݹݺݻݼݽݾݿހށނރބޅކއވމފދތލގޏސޑޒޓޔޕޖޗޘޙޚޛޜޝޞޟޠޡޢޣ"), "ޤޥަާިީުޫެޭޮޯްޱ\u07b2\u07b3\u07b4\u07b5\u07b6\u07b7\u07b8\u07b9\u07ba\u07bb\u07bc\u07bd\u07be\u07bf߀߁߂߃߄߅߆߇߈߉ߊߋߌߍߎߏߐߑߒߓߔߕߖߗߘߙߚߛߜߝߞߟߠߡߢߣߤߥߦߧߨߩߪ߲߫߬߭߮߯߰߱߳ߴߵ߶߷߸߹ߺ\u07fb\u07fc߽߾߿ࠀࠁࠂࠃࠄࠅࠆࠇࠈࠉࠊࠋࠌࠍࠎࠏࠐࠑࠒࠓࠔࠕࠖࠗ࠘࠙ࠚࠛࠜࠝࠞࠟࠠࠡࠢࠣ", "ࠤࠥࠦࠧࠨࠩࠪࠫࠬ࠭\u082e\u082f࠰࠱࠲࠳࠴࠵࠶࠷࠸࠹࠺࠻࠼࠽࠾\u083fࡀࡁࡂࡃࡄࡅࡆࡇࡈࡉࡊࡋࡌࡍࡎࡏࡐࡑࡒࡓࡔࡕࡖࡗࡘ࡙࡚࡛\u085c\u085d࡞\u085fࡠࡡࡢࡣࡤࡥࡦࡧࡨࡩࡪ\u086b\u086c\u086d\u086e\u086fࡰࡱࡲࡳࡴࡵࡶࡷࡸࡹࡺࡻࡼࡽࡾࡿࢀࢁࢂࢃࢄࢅࢆࢇ࢈ࢉࢊࢋࢌࢍࢎ\u088f\u0890\u0891\u0892\u0893\u0894\u0895\u0896\u0897࢙࢚࢛࢘࢜࢝࢞࢟ࢠࢡࢢࢣ"), "ࢤࢥࢦࢧࢨࢩࢪࢫࢬࢭࢮࢯࢰࢱࢲࢳࢴࢵࢶࢷࢸࢹࢺࢻࢼࢽࢾࢿࣀࣁࣂࣃࣄࣅࣆࣇࣈࣉ࣏࣐࣑࣒࣓࣊࣋࣌࣍࣎ࣔࣕࣖࣗࣘࣙࣚࣛࣜࣝࣞࣟ࣠࣡\u08e2ࣰࣱࣲࣣࣦࣩ࣭࣮࣯ࣶࣹࣺࣤࣥࣧࣨ࣪࣫࣬ࣳࣴࣵࣷࣸࣻࣼࣽࣾࣿऀँंःऄअआइईउऊऋऌऍऎएऐऑऒओऔकखगघङचछजझञटठडढण", "तथदधनऩपफबभमयरऱलळऴवशषसहऺऻ़ऽािीुूृॄॅॆेैॉॊोौ्ॎॏॐ॒॑॓॔ॕॖॗक़ख़ग़ज़ड़ढ़फ़य़ॠॡॢॣ।॥०१२३४५६७८९॰ॱॲॳॴॵॶॷॸॹॺॻॼॽॾॿঀঁংঃ\u0984অআইঈউঊঋঌ\u098d\u098eএঐ\u0991\u0992ওঔকখগঘঙচছজঝঞটঠডঢণ"), "তথদধন\u09a9পফবভমযর\u09b1ল\u09b3\u09b4\u09b5শষসহ\u09ba\u09bb়ঽািীুূৃৄ\u09c5\u09c6েৈ\u09c9\u09caোৌ্ৎ\u09cf\u09d0\u09d1\u09d2\u09d3\u09d4\u09d5\u09d6ৗ\u09d8\u09d9\u09da\u09dbড়ঢ়\u09deয়ৠৡৢৣ\u09e4\u09e5০১২৩৪৫৬৭৮৯ৰৱ৲৳৴৵৶৷৸৹৺৻ৼ৽৾\u09ff\u0a00ਁਂਃ\u0a04ਅਆਇਈਉਊ\u0a0b\u0a0c\u0a0d\u0a0eਏਐ\u0a11\u0a12ਓਔਕਖਗਘਙਚਛਜਝਞਟਠਡਢਣ", "ਤਥਦਧਨ\u0a29ਪਫਬਭਮਯਰ\u0a31ਲਲ਼\u0a34ਵਸ਼\u0a37ਸਹ\u0a3a\u0a3b਼\u0a3dਾਿੀੁੂ\u0a43\u0a44\u0a45\u0a46ੇੈ\u0a49\u0a4aੋੌ੍\u0a4e\u0a4f\u0a50ੑ\u0a52\u0a53\u0a54\u0a55\u0a56\u0a57\u0a58ਖ਼ਗ਼ਜ਼ੜ\u0a5dਫ਼\u0a5f\u0a60\u0a61\u0a62\u0a63\u0a64\u0a65੦੧੨੩੪੫੬੭੮੯ੰੱੲੳੴੵ੶\u0a77\u0a78\u0a79\u0a7a\u0a7b\u0a7c\u0a7d\u0a7e\u0a7f\u0a80ઁંઃ\u0a84અઆઇઈઉઊઋઌઍ\u0a8eએઐઑ\u0a92ઓઔકખગઘઙચછજઝઞટઠડઢણ"), "તથદધન\u0aa9પફબભમયર\u0ab1લળ\u0ab4વશષસહ\u0aba\u0abb઼ઽાિીુૂૃૄૅ\u0ac6ેૈૉ\u0acaોૌ્\u0ace\u0acfૐ\u0ad1\u0ad2\u0ad3\u0ad4\u0ad5\u0ad6\u0ad7\u0ad8\u0ad9\u0ada\u0adb\u0adc\u0add\u0ade\u0adfૠૡૢૣ\u0ae4\u0ae5૦૧૨૩૪૫૬૭૮૯૰૱\u0af2\u0af3\u0af4\u0af5\u0af6\u0af7\u0af8ૹૺૻૼ૽૾૿\u0b00ଁଂଃ\u0b04ଅଆଇଈଉଊଋଌ\u0b0d\u0b0eଏଐ\u0b11\u0b12ଓଔକଖଗଘଙଚଛଜଝଞଟଠଡଢଣ", "ତଥଦଧନ\u0b29ପଫବଭମଯର\u0b31ଲଳ\u0b34ଵଶଷସହ\u0b3a\u0b3b଼ଽାିୀୁୂୃୄ\u0b45\u0b46େୈ\u0b49\u0b4aୋୌ୍\u0b4e\u0b4f\u0b50\u0b51\u0b52\u0b53\u0b54୕ୖୗ\u0b58\u0b59\u0b5a\u0b5bଡ଼ଢ଼\u0b5eୟୠୡୢୣ\u0b64\u0b65୦୧୨୩୪୫୬୭୮୯୰ୱ୲୳୴୵୶୷\u0b78\u0b79\u0b7a\u0b7b\u0b7c\u0b7d\u0b7e\u0b7f\u0b80\u0b81ஂஃ\u0b84அஆஇஈஉஊ\u0b8b\u0b8c\u0b8dஎஏஐ\u0b91ஒஓஔக\u0b96\u0b97\u0b98ஙச\u0b9bஜ\u0b9dஞட\u0ba0\u0ba1\u0ba2ண"), "த\u0ba5\u0ba6\u0ba7நனப\u0bab\u0bac\u0badமயரறலளழவஶஷஸஹ\u0bba\u0bbb\u0bbc\u0bbdாிீுூ\u0bc3\u0bc4\u0bc5ெேை\u0bc9ொோௌ்\u0bce\u0bcfௐ\u0bd1\u0bd2\u0bd3\u0bd4\u0bd5\u0bd6ௗ\u0bd8\u0bd9\u0bda\u0bdb\u0bdc\u0bdd\u0bde\u0bdf\u0be0\u0be1\u0be2\u0be3\u0be4\u0be5௦௧௨௩௪௫௬௭௮௯௰௱௲௳௴௵௶௷௸௹௺\u0bfb\u0bfc\u0bfd\u0bfe\u0bffఀఁంఃఄఅఆఇఈఉఊఋఌ\u0c0dఎఏఐ\u0c11ఒఓఔకఖగఘఙచఛజఝఞటఠడఢణ", "తథదధన\u0c29పఫబభమయరఱలళఴవశషసహ\u0c3a\u0c3b఼ఽాిీుూృౄ\u0c45ెేై\u0c49ొోౌ్\u0c4e\u0c4f\u0c50\u0c51\u0c52\u0c53\u0c54ౕౖ\u0c57ౘౙౚ\u0c5b\u0c5cౝ\u0c5e\u0c5fౠౡౢౣ\u0c64\u0c65౦౧౨౩౪౫౬౭౮౯\u0c70\u0c71\u0c72\u0c73\u0c74\u0c75\u0c76౷౸౹౺౻౼౽౾౿ಀಁಂಃ಄ಅಆಇಈಉಊಋಌ\u0c8dಎಏಐ\u0c91ಒಓಔಕಖಗಘಙಚಛಜಝಞಟಠಡಢಣ"), "ತಥದಧನ\u0ca9ಪಫಬಭಮಯರಱಲಳ\u0cb4ವಶಷಸಹ\u0cba\u0cbb಼ಽಾಿೀುೂೃೄ\u0cc5ೆೇೈ\u0cc9ೊೋೌ್\u0cce\u0ccf\u0cd0\u0cd1\u0cd2\u0cd3\u0cd4ೕೖ\u0cd7\u0cd8\u0cd9\u0cda\u0cdb\u0cdcೝೞ\u0cdfೠೡೢೣ\u0ce4\u0ce5೦೧೨೩೪೫೬೭೮೯\u0cf0ೱೲೳ\u0cf4\u0cf5\u0cf6\u0cf7\u0cf8\u0cf9\u0cfa\u0cfb\u0cfc\u0cfd\u0cfe\u0cffഀഁംഃഄഅആഇഈഉഊഋഌ\u0d0dഎഏഐ\u0d11ഒഓഔകഖഗഘങചഛജഝഞടഠഡഢണ", "തഥദധനഩപഫബഭമയരറലളഴവശഷസഹഺ഻഼ഽാിീുൂൃൄ\u0d45െേൈ\u0d49ൊോൌ്ൎ൏\u0d50\u0d51\u0d52\u0d53ൔൕൖൗ൘൙൚൛൜൝൞ൟൠൡൢൣ\u0d64\u0d65൦൧൨൩൪൫൬൭൮൯൰൱൲൳൴൵൶൷൸൹ൺൻർൽൾൿ\u0d80ඁංඃ\u0d84අආඇඈඉඊඋඌඍඎඏඐඑඒඓඔඕඖ\u0d97\u0d98\u0d99කඛගඝඞඟචඡජඣ"), "ඤඥඦටඨඩඪණඬතථදධන\u0db2ඳපඵබභමඹයර\u0dbcල\u0dbe\u0dbfවශෂසහළෆ\u0dc7\u0dc8\u0dc9්\u0dcb\u0dcc\u0dcd\u0dceාැෑිීු\u0dd5ූ\u0dd7ෘෙේෛොෝෞෟ\u0de0\u0de1\u0de2\u0de3\u0de4\u0de5෦෧෨෩෪෫෬෭෮෯\u0df0\u0df1ෲෳ෴\u0df5\u0df6\u0df7\u0df8\u0df9\u0dfa\u0dfb\u0dfc\u0dfd\u0dfe\u0dff\u0e00กขฃคฅฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยร", "ฤลฦวศษสหฬอฮฯะัาำิีึืฺุู\u0e3b\u0e3c\u0e3d\u0e3e฿เแโใไๅๆ็่้๊๋์ํ๎๏๐๑๒๓๔๕๖๗๘๙๚๛\u0e5c\u0e5d\u0e5e\u0e5f\u0e60\u0e61\u0e62\u0e63\u0e64\u0e65\u0e66\u0e67\u0e68\u0e69\u0e6a\u0e6b\u0e6c\u0e6d\u0e6e\u0e6f\u0e70\u0e71\u0e72\u0e73\u0e74\u0e75\u0e76\u0e77\u0e78\u0e79\u0e7a\u0e7b\u0e7c\u0e7d\u0e7e\u0e7f\u0e80ກຂ\u0e83ຄ\u0e85ຆງຈຉຊ\u0e8bຌຍຎຏຐຑຒຓດຕຖທຘນບປຜຝພຟຠມຢຣ"), "\u0ea4ລ\u0ea6ວຨຩສຫຬອຮຯະັາຳິີຶື຺ຸູົຼຽ\u0ebe\u0ebfເແໂໃໄ\u0ec5ໆ\u0ec7່້໊໋໌ໍ໎\u0ecf໐໑໒໓໔໕໖໗໘໙\u0eda\u0edbໜໝໞໟ\u0ee0\u0ee1\u0ee2\u0ee3\u0ee4\u0ee5\u0ee6\u0ee7\u0ee8\u0ee9\u0eea\u0eeb\u0eec\u0eed\u0eee\u0eef\u0ef0\u0ef1\u0ef2\u0ef3\u0ef4\u0ef5\u0ef6\u0ef7\u0ef8\u0ef9\u0efa\u0efb\u0efc\u0efd\u0efe\u0effༀ༁༂༃༄༅༆༇༈༉༊་༌།༎༏༐༑༒༓༔༕༖༗༘༙༚༛༜༝༞༟༠༡༢༣", "༤༥༦༧༨༩༪༫༬༭༮༯༰༱༲༳༴༵༶༷༸༹༺༻༼༽༾༿ཀཁགགྷངཅཆཇ\u0f48ཉཊཋཌཌྷཎཏཐདདྷནཔཕབབྷམཙཚཛཛྷཝཞཟའཡརལཤཥསཧཨཀྵཪཫཬ\u0f6d\u0f6e\u0f6f\u0f70ཱཱཱིིུུྲྀཷླྀཹེཻོཽཾཿ྄ཱྀྀྂྃ྅྆྇ྈྉྊྋྌྍྎྏྐྑྒྒྷྔྕྖྗ\u0f98ྙྚྛྜྜྷྞྟྠྡྡྷྣ"), "ྤྥྦྦྷྨྩྪྫྫྷྭྮྯྰྱྲླྴྵྶྷྸྐྵྺྻྼ\u0fbd྾྿࿀࿁࿂࿃࿄࿅࿆࿇࿈࿉࿊࿋࿌\u0fcd࿎࿏࿐࿑࿒࿓࿔࿕࿖࿗࿘࿙࿚\u0fdb\u0fdc\u0fdd\u0fde\u0fdf\u0fe0\u0fe1\u0fe2\u0fe3\u0fe4\u0fe5\u0fe6\u0fe7\u0fe8\u0fe9\u0fea\u0feb\u0fec\u0fed\u0fee\u0fef\u0ff0\u0ff1\u0ff2\u0ff3\u0ff4\u0ff5\u0ff6\u0ff7\u0ff8\u0ff9\u0ffa\u0ffb\u0ffc\u0ffd\u0ffe\u0fffကခဂဃငစဆဇဈဉညဋဌဍဎဏတထဒဓနပဖဗဘမယရလဝသဟဠအဢဣ")
    pfLoadedMap_nodes = []
    i1 = 0
    i2 = 0
    #Decompress nodes
    for i1 in range(len(pfDecompress[0])):
        for i2 in range(0, strLen(pfDecompress[0][i1]), 3):
            pfLoadedMap_nodes.append(vect(compressionTable.strIndex(pfDecompress[0][i1].charAt(i2)), compressionTable.strIndex(pfDecompress[0][i1].charAt(i2 + 1)), compressionTable.strIndex(pfDecompress[0][i1].charAt(i2 + 2))))
            wait()
    #Decompress neighbors
    decompressionState = 0
    currentNeighbors = []
    for i1 in range(len(pfDecompress[1])):
        for i2 in range(strLen(pfDecompress[1][i1])):
            next = compressionTable.strIndex(pfDecompress[1][i1].charAt(i2))
            #Next is the neighbor.
            if decompressionState == 0:
                #Current node is terminated.
                if not next:
                    pfLoadedMap_neighbors.append([currentNeighbors])
                    #Reset current neighbors array
                    currentNeighbors = []
                    #Next neighbor found.
                else:
                    decompressionState = 1
                    currentNeighbors.append([[next - 1, []]])
                #Looking for attributes.
            elif decompressionState == 1:
                #Current neighbor is terminated
                if not next:
                    decompressionState = 0
                    #Next attribute located
                else:
                    currentNeighbors[len(currentNeighbors) - 1] = [currentNeighbors.last()[0], currentNeighbors.last()[1].concat(next - 1)]
            wait()
    compressionTable = null


