<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<c:set var="pinSvg"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21s7-6.5 7-12a7 7 0 1 0-14 0c0 5.5 7 12 7 12z"/><circle cx="12" cy="9" r="2.5"/></svg></c:set>
<c:set var="chevSvg"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 6l6 6-6 6"/></svg></c:set>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade" value="${cms.isEditMode}" />

<section class="element type-gb-references refs${setCssWrapperAll}" id="referenzen" aria-label="${fn:escapeXml(value.Title)}"><%----%>
    <div class="wrap"><%----%>
        <div class="refs-head" data-reveal-stagger><%----%>
            <c:if test="${value.Eyebrow.isSet}"><span class="eyebrow"><span class="dot"></span>${value.Eyebrow}</span></c:if><%----%>
            <h2 ${ade ? content.rdfa.Title : ''}>${value.Title}</h2><%----%>
            <c:if test="${value.Intro.isSet}"><p>${value.Intro}</p></c:if><%----%>
        </div><%----%>

        <div class="refs-list"><%----%>
            <c:forEach var="ref" items="${content.valueList.Reference}"><%----%>
                <c:set var="hasLink" value="${ref.value.Link.exists and ref.value.Link.value.URI.isSet}" /><%----%>
                <m:link link="${hasLink ? ref.value.Link : null}" css="refs-toggle"><%----%>
                    <span class="refs-toggle-pin">${pinSvg}</span><%----%>
                    <span class="refs-toggle-main"><%----%>
                        <span class="refs-toggle-title">${ref.value.Title}</span><%----%>
                        <c:if test="${ref.value.Subtitle.isSet}"><span class="refs-toggle-sub">${ref.value.Subtitle}</span></c:if><%----%>
                    </span><%----%>
                    <c:if test="${ref.value.Count.isSet}"><span class="refs-toggle-count">${ref.value.Count}</span></c:if><%----%>
                    <span class="refs-toggle-chevron">${chevSvg}</span><%----%>
                </m:link><%----%>
            </c:forEach><%----%>
        </div><%----%>
    </div><%----%>
</section><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
