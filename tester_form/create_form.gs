/**
 * Fruit Matching Puzzle - Tester Checklist (Pass / Failed)
 * Paano gamitin:
 *   1. Pumunta sa https://script.google.com  ->  New project
 *   2. Burahin ang laman, i-paste ang buong code na ito, i-save (Ctrl+S)
 *   3. Piliin ang function "createTestForm" sa taas, pindutin ang Run
 *   4. Payagan ang permissions (Review permissions -> piliin ang account -> Advanced -> Go to ... -> Allow)
 *   5. Buksan ang Execution log: nandoon ang 2 link (Edit link at Share link para sa testers)
 */
function createTestForm() {
  var form = FormApp.create('Fruit Matching Puzzle - Tester Checklist (Pass / Failed)');
  form.setDescription(
    'Salamat sa pag-test ng Fruit Matching Puzzle!\n\n' +
    'Subukan ang bawat item. Piliin ang PASS kung gumana nang tama, FAILED kung hindi.\n' +
    'Kung may FAILED, isulat sa dulo ng form ang numero ng test at ang nangyari.'
  );
  form.setCollectEmail(false);
  form.setProgressBar(true);
  form.setShowLinkToRespondAgain(false);
  form.setConfirmationMessage('Salamat sa pag-test! Malaking tulong ito. 🍓');

  // ---------- Tester info ----------
  form.addSectionHeaderItem().setTitle('Impormasyon ng Tester');
  form.addTextItem().setTitle('Pangalan o palayaw (optional)');
  form.addTextItem().setTitle('Phone brand at model (hal. Xiaomi Redmi 12)').setRequired(true);
  form.addTextItem().setTitle('Android version (hal. Android 14)').setRequired(true);
  form.addTextItem().setTitle('App version (nasa Settings, sa pinakababa, hal. 1.2.0)').setRequired(true);

  // ---------- Mga test ----------
  var sections = [
    { title: 'A. Install at Simula', tests: [
      '1. Na-install ang app at nagbubukas nang walang crash',
      '2. Lumalabas ang Splash screen (loading) at kusang pumupunta sa Home',
      '3. Tama ang icon at pangalan ng app ("Fruit Matching Puzzle") sa home screen ng phone',
      '4. Tumutunog ang background music',
      '5. Kita ang buong screen (walang naputol o nagtatabing na bahagi)'
    ]},
    { title: 'B. Home at Menu', tests: [
      '6. Kita sa Home ang profile, coins, mascot, at 4 na menu (Endless Rush, Levels, Shop, High Scores)',
      '7. Bumubukas ang Daily Reward at nakaka-claim ng reward',
      '8. Bumubukas ang Book (Paano Maglaro)',
      '9. Bumubukas ang Profile at napapalitan ang pangalan',
      '10. Bumubukas ang Settings',
      '11. Bumubukas ang Feedback'
    ]},
    { title: 'C. Levels at Gameplay', tests: [
      '12. Ipinapakita ng Levels ang 20 level; Level 1 lang ang bukas sa simula',
      '13. Nakatago ang cards at nagsa-shuffle ng 3 segundo bago magsimula ang laro',
      '14. Kapag tinap ang card, bumubuka ito (may animation at tunog)',
      '15. Ang magkaparehong cards ay nananatiling bukas; ang hindi magkapareho ay bumabalik sa tago',
      '16. Tama ang takbo ng timer (bumababa bawat segundo)',
      '17. Lumalabas ang COMBO kapag magkakasunod ang tama',
      '18. Lumalabas ang "TIME\'S UP" kapag naubos ang oras; gumagana ang RESTART at MENU',
      '19. Lumalabas ang "LEVEL CLEAR" na may stars, score at coins; gumagana ang NEXT, RESTART at MENU',
      '20. Nabubuksan ang susunod na level pagkatapos matapos ang isa',
      '21. Gumagana ang BACK at NEXT sa ibaba ng laro',
      '22. Gumagana ang Pause (PLAY, RESTART, OPTIONS, QUIT) at humihinto ang timer habang naka-pause'
    ]},
    { title: 'D. Power-ups at Shop', tests: [
      '23. Gumagana ang Peek, Extra Time (+15 segundo) at Hint',
      '24. May mensahe kapag wala nang power-up at pinindot pa',
      '25. Nakakabili ng power-up sa Shop at bumababa ang coins',
      '26. Nakakabili at nagagamit ang card theme (nagbabago ang kulay ng likod ng cards)',
      '27. May mensahe kapag kulang ang coins at walang nabibili'
    ]},
    { title: 'E. Endless Rush', tests: [
      '28. Nagsisimula sa 2:00 pagkatapos ng shuffle',
      '29. Kapag natapos ang round: dagdag na 50 segundo at may coin reward',
      '30. May "GAME OVER" kapag naubos ang oras at nasasave sa High Scores (Top Endless Runs)'
    ]},
    { title: 'F. Profile Picture at Stars', tests: [
      '31. Nakikita ang mga prutas na profile picture, mabibili gamit ang stars, at lumalabas sa Home ang napili'
    ]},
    { title: 'G. Settings, Sound at Feedback', tests: [
      '32. Gumagana ang Music on/off, volume, at pagpapalit ng music track',
      '33. Gumagana ang Sound Effects on/off at volume',
      '34. May internet: gumagana ang Send sa Feedback at may lumalabas na success message',
      '35. Walang internet: hindi nag-crash ang Feedback at may paliwanag o alternatibo'
    ]},
    { title: 'H. Katatagan at Itsura', tests: [
      '36. Nananatili ang progress (stars, coins, settings) pagkatapos isara at buksan ulit ang app',
      '37. Walang crash o freeze sa loob ng 10 minutong paglalaro',
      '38. Gumagana pa rin pagkatapos lumipat sa ibang app at bumalik (huminto at bumalik ang music)',
      '39. Madaling basahin ang mga text, walang nagtatamaan o naputol',
      '40. Maayos ang takbo ng laro (walang lag)',
      '41. Walang ads o hindi angkop na laman'
    ]}
  ];

  sections.forEach(function (s) {
    form.addPageBreakItem().setTitle(s.title);
    form.addGridItem()
        .setTitle(s.title + ' - Pass o Failed?')
        .setRows(s.tests)
        .setColumns(['Pass', 'Failed'])
        .setRequired(true);
  });

  // ---------- Pangwakas ----------
  form.addPageBreakItem().setTitle('I. Pangwakas');
  form.addMultipleChoiceItem()
      .setTitle('Kabuuang resulta ng app para sa iyo')
      .setChoiceValues(['Pass', 'Failed'])
      .setRequired(true);
  form.addParagraphTextItem()
      .setTitle('Kung may FAILED: isulat ang numero ng test at ang nangyari (optional)')
      .setHelpText('Halimbawa: "#18 - Hindi lumalabas ang TIME\'S UP, nag-freeze ang screen."');

  Logger.log('EDIT link (para sa iyo): ' + form.getEditUrl());
  Logger.log('SHARE link (ibigay sa testers): ' + form.getPublishedUrl());
}
