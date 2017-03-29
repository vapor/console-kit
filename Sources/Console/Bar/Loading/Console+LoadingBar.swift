extension ConsoleProtocol {
	/**
		Creates a LoadingBar using the console.
	*/
    public func loadingBar(
        title: String = "",
        width: Int = 25,
        barStyle: ConsoleStyle = .info,
        titleStyle: ConsoleStyle = .plain,
        animated: Bool = true
    ) -> LoadingBar {
        return LoadingBar(
            console: self,
            title: title,
            width: width,
            barStyle: barStyle,
            titleStyle: titleStyle,
            animated: animated
        )
    }
}
