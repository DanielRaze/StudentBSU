import UIKit

class NotesViewController: UIViewController {
    
    private var notes: [Note] = []
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Заметки"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "0 заметок"
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.appPrimary, for: .normal)
        button.tintColor = .appPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topPanelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStack, plusButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.register(NoteCardCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    @objc private func addButtonTapped() {
        let note = Note()
        NoteDataManager.shared.saveNote(note)
        let detailVC = NoteDetailViewController(note: note)
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    private func loadNotes() {
        notes = NoteDataManager.shared.fetchNotes()
        collectionView.reloadData()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topPanelStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            topPanelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topPanelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        navigationItem.hidesBackButton = false
        navigationController?.isNavigationBarHidden = true
        view.addSubview(topPanelStack)
        view.addSubview(separatorView)
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadNotes()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        let fetchedNotes = NoteDataManager.shared.fetchNotes()
        self.notes = fetchedNotes
        
        collectionView.reloadData()
        
        subtitleLabel.text = "\(notes.count) заметок"
    }
}

extension NotesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NoteCardCell else { return UICollectionViewCell() }
        let note = notes[indexPath.item]
        cell.configure(with: note)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = notes[indexPath.item]
        let detailVC = NoteDetailViewController(note: note)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


